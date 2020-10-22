# EM说明

要使用EM就必须使用EE版的oracle，现在选择的镜像是loliconneko/oracle-ee-11g, 此镜像在制作镜像时已经配置了em，但是由于主机网络的变化导致em无法启动，
目前的解决方法是手动重建em.

首先进入oracle的container的shell
```bash
su oracle
export ORACLE_SID=EE
export ORACLE_UNQNAME=EE
# 删除配置
emca -deconfig dbcontrol db
# 删除repository
emca -repos drop
# 重建
emca -config dbcontrol db -repos create
emctl start dbconsole
```

# 记录

表空间

```sql
CREATE SMALLFILE TABLESPACE "CUITAO" DATAFILE '/u01/app/oracle/oradata/EE/cuitao.dbf' SIZE 1G AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO
```

用户
```sql
CREATE USER "CUITAO" PROFILE "DEFAULT" IDENTIFIED BY "*******" DEFAULT TABLESPACE "CUITAO" TEMPORARY TABLESPACE "TEMP" ACCOUNT UNLOCK
GRANT "CONNECT" TO "CUITAO"
GRANT "DBA" TO "CUITAO"
```