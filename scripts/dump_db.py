#!/usr/bin/env python3
"""DMMS 資料庫 SQL 備份產生器：連 SQL Server DMMS 庫，輸出 db/DMMS-backup-<date>.sql
（schema + identity 保留 + 資料 INSERT，依 FK 依賴排序，可直接在空庫還原）"""
import pymssql, json, re, datetime, sys

CFG = json.load(open('src/DMMS.Web/appsettings.Development.json'))
CS = CFG['ConnectionStrings']['DefaultConnection']
m = re.search(r'Server=([^,;]+),(\d+);.*?User Id=([^;]+);.*?Password=([^;]+);', CS)
server, port, user, pwd = m.group(1), int(m.group(2)), m.group(3), m.group(4)

OUT = f"db/DMMS-backup-{datetime.date.today():%Y%m%d}.sql"
SKIP_TABLES = {'__EFMigrationsHistory'}

def sql_quote(v, col_type):
    """轉成 T-SQL literal。col_type 為 SQL 型別名稱。"""
    if v is None: return 'NULL'
    t = col_type.lower()
    # 字串類（nvarchar/varchar/text/xml）一律用 N'...' Unicode literal，避免非 ASCII 依 codepage 誤解
    if 'char' in t or 'text' in t or 'xml' in t:
        return "N'" + str(v).replace("'", "''") + "'"
    if 'uniqueidentifier' in t or 'datetime' in t or 'date' in t or 'time' in t:
        return "'" + str(v).replace("'", "''") + "'"
    if 'binary' in t or 'image' in t:
        return '0x' + bytes(v).hex()
    if 'bit' in t:
        return '1' if v else '0'
    return str(v)

def main():
    conn = pymssql.connect(server=server, port=port, user=user, password=pwd,
                           database='DMMS', charset='utf8', tds_version='7.4', login_timeout=15)
    cur = conn.cursor(as_dict=True)

    # 1. 資料表清單 + 註解行
    cur.execute("""SELECT t.name FROM sys.tables t JOIN sys.schemas s ON t.schema_id=s.schema_id
                   WHERE s.name='dmms' AND t.name NOT IN (SELECT value FROM STRING_SPLIT(%s, ','))""",
                ','.join(SKIP_TABLES))
    tables = [r['name'] for r in cur.fetchall()]

    # 2. FK 依賴：child -> parent（child 需在 parent 之後 INSERT、之前 DROP）
    cur.execute("""SELECT OBJECT_NAME(fk.parent_object_id) child, OBJECT_NAME(fk.referenced_object_id) parent
                   FROM sys.foreign_keys fk JOIN sys.schemas s ON fk.schema_id=s.schema_id
                   WHERE s.name='dmms'""")
    deps = [(r['child'], r['parent']) for r in cur.fetchall()]

    def topo(rev=False):
        """rev=False: parent 先(child 後)。rev=True: child 先。"""
        ordered, seen = [], set()
        def visit(t):
            if t in seen: return
            seen.add(t)
            for c, p in deps:
                target = p if not rev else c
                nxt = c if not rev else p
                if target == t and nxt in tables: visit(nxt)
            ordered.append(t)
        for t in tables: visit(t)
        return [t for t in ordered if t in tables]

    ins_order = topo(False)   # CREATE/INSERT：parent first
    drop_order = topo(True)   # DROP：child first

    # 3. 每表欄位 meta
    colmeta = {}
    pk_cols = {}
    cur.execute("""SELECT c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH,
                          c.IS_NULLABLE, c.NUMERIC_PRECISION, c.NUMERIC_SCALE, c.DATETIME_PRECISION,
                          COLUMNPROPERTY(OBJECT_ID('dmms.'+c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') IsIdentity,
                          c.COLUMN_DEFAULT
                   FROM INFORMATION_SCHEMA.COLUMNS c
                   WHERE c.TABLE_SCHEMA='dmms' ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION""")
    for r in cur.fetchall():
        colmeta.setdefault(r['TABLE_NAME'], []).append(r)
    cur.execute("""SELECT tc.TABLE_NAME, k.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                   JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k ON tc.CONSTRAINT_NAME=k.CONSTRAINT_NAME
                   WHERE tc.CONSTRAINT_TYPE='PRIMARY KEY' AND tc.TABLE_SCHEMA='dmms'""")
    for r in cur.fetchall():
        pk_cols.setdefault(r['TABLE_NAME'], []).append(r['COLUMN_NAME'])

    def col_type_of(c):
        t = c['DATA_TYPE'].lower()
        if t in ('char', 'varchar', 'nvarchar'):
            l = c['CHARACTER_MAXIMUM_LENGTH']
            return f"{t}({l if l != -1 else 'max'})"
        if t == 'decimal':
            return f"decimal({c['NUMERIC_PRECISION']},{c['NUMERIC_SCALE']})"
        if t == 'datetime2':
            return f"datetime2({c['DATETIME_PRECISION'] or 7})"
        if t == 'datetimeoffset':
            return f"datetimeoffset({c['DATETIME_PRECISION'] or 7})"
        if t == 'time':
            return f"time({c['DATETIME_PRECISION'] or 7})"
        return t

    lines = []
    A = lines.append
    A(f"-- ===================================================")
    A(f"-- DMMS (外送菜單管理系統) 資料庫備份")
    A(f"-- 產生時間: {datetime.datetime.now():%Y-%m-%d %H:%M:%S}")
    A(f"-- 資料庫:   DMMS (schema: dmms)")
    A(f"-- 還原:     sqlcmd -S <server> -U sa -P <pwd> -C -d DMMS -i {OUT.split('/')[-1]}")
    A(f"-- ===================================================")
    A("SET NOCOUNT ON;")
    A("GO")
    A("IF SCHEMA_ID('dmms') IS NULL EXEC('CREATE SCHEMA dmms');")
    A("GO")
    A("")

    # 4. DROP（child first）
    for t in drop_order:
        A(f"IF OBJECT_ID('dmms.[{t}]', 'U') IS NOT NULL DROP TABLE dmms.[{t}];")
    A("GO")
    A("")

    # 5. CREATE
    for t in ins_order:
        cols = colmeta[t]
        defs = []
        for c in cols:
            coldef = f"    [{c['COLUMN_NAME']}] {col_type_of(c)}"
            if c['IsIdentity']: coldef += " IDENTITY(1,1)"
            coldef += " NOT NULL" if c['IS_NULLABLE'] == 'NO' else " NULL"
            if c['COLUMN_DEFAULT']:
                coldef += f" DEFAULT {c['COLUMN_DEFAULT']}"
            defs.append(coldef)
        if pk_cols.get(t):
            pks = ', '.join(f"[{c}]" for c in pk_cols[t])
            defs.append(f"    CONSTRAINT [PK_{t}] PRIMARY KEY ({pks})")
        A(f"CREATE TABLE dmms.[{t}] (")
        A(",\n".join(defs))
        A(");")
    A("GO")
    A("")

    # 6. INSERT（保留原 Id → identity insert）
    for t in ins_order:
        cols = colmeta[t]
        names = [c['COLUMN_NAME'] for c in cols]
        id_cols = [c['COLUMN_NAME'] for c in cols if c['IsIdentity']]
        has_identity = bool(id_cols)
        cur.execute(f"SELECT * FROM dmms.[{t}]")
        rows = cur.fetchall()
        A(f"-- {t}: {len(rows)} 列")
        if has_identity:
            A(f"SET IDENTITY_INSERT dmms.[{t}] ON;")
        col_list = ', '.join(f"[{n}]" for n in names)
        for row in rows:
            vals = ', '.join(sql_quote(row[n], next(c['DATA_TYPE'] for c in cols if c['COLUMN_NAME'] == n)) for n in names)
            A(f"INSERT INTO dmms.[{t}] ({col_list}) VALUES ({vals});")
        if has_identity:
            A(f"SET IDENTITY_INSERT dmms.[{t}] OFF;")
        A("")
    A("GO")
    A("")
    A("-- 備份完成")
    conn.close()

    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f"OK {OUT}: {len(lines)} lines, {len(ins_order)} tables")

if __name__ == '__main__':
    main()
