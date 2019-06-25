#!/bin/bash

cat > /etc/yum.repos.d/emr-apps.repo <<EOF
[emr-applications]
name = EMR Applications Repository
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-emr
enabled = 1
baseurl = https://s3.amazonaws.com/repo.us-east-1.emr.amazonaws.com/apps-repository/emr-5.24.0/a536ac12-f2f9-43e2-88ae-1a1e6d740eb9
priority = 5
gpgcheck = 1
EOF

cat > /etc/yum.repos.d/emr-platform.repo <<EOF
[emr-platform]
name = EMR Platform Repository
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-emr
enabled = 1
baseurl = https://s3.amazonaws.com/repo.us-east-1.emr.amazonaws.com/platform-repository/1.17.0/a2676858-5c70-4eb2-b063-5bb11ea995b1
priority = 5
gpgcheck = 1
EOF

cat > /etc/pki/rpm-gpg/RPM-GPG-KEY-emr <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFjwMVkBCADNq4MWao1yIcvYm5gy3auQp/VzwrR0z8Kt5NYknZ2yGgJJusLB
ndrfQJEmEOP+UOCJNsDK18lQbguwlKns+267ZXR2j+IkjVYp5uSs4WcoP270a5jP
ShWBCafpv6yLyq9h2x5EqWpUKSI8bGxLkHzWsQEJq7IRDsFkdL/hM6fEgNvX/ItK
llBl8uZqvk9O1l71AzhQN/YXxujgAU8jxNCA9bSYPoSKb6NSiagVnZDKlL5/GvlU
k5sPR+HtL9Zj2A4Vt4p5RlWZ6TRKP4Yh4e6uJRkqNILiPCUOJT5PhfAR8JmG2br+
l9fd4TyMheEg3US3747Her97+1gZwXxexNzDABEBAAG0HUVNUiBBV1MgPGVtci10
ZWFtQGFtYXpvbi5jb20+iQE/BBMBCAApBQJY8DFZAhsDBQklmAYABwsJCAcDAgEG
FQgCCQoLBBYCAwECHgECF4AACgkQScW3nfEbsNvjoQf/fJco6A2IjIGWUp6NBOvj
K5ng1NSxuGh6ZPutMPmMTh6ItLfbTz08Tsr43UyUSrEnnrNPID/BWfcSu72ov1kH
XrBGGJBJjpAP/MP53+SLsaRmG6MB/7mqPcrBaqNF+Ynzfhld2v55lKxK5pXaCJqe
7i2m3HNRyxXe/hWS1aWvEUtRAgA8FxdHTtn3FAqeIe6vqb+/RRKZmzRidYKp7z7n
CL4IrT/xdjzU+9Q8PlrOG3zYYXzrV/eSTBeq3PpCtIMXsE5QT7jOAb/E8pwG5NRt
P5JG/RaFw3Ovow2+Y0udEM3Xz+Va+DipnAHbk7o6GfCdeod86VG8Dy6Tr3m60wmF
2rkBDQRY8DFZAQgAtB2FTjSluh7Hyy83rcqb+57po1KbGunEGsFz+i8sTNv8aNGa
+dshJnaFJXsAKFaTzSRsbuk91DmmPx1BuV/q/uF8n/WGScu5HOcKaKBGDozu0SDj
Qe4sPl2uKcQjckBL1VwuGaDh2LZaEwWzScpAjgqJvCB4E7vVBPQAbQCTDomz9C2X
EwJFoyeIpPKrpqjLkODBZLVL4aQgjqtQVpTUTZNh1yWZnwjvQ9ZXKLQyycjMc/51
liGxlkO+e8Uu3zlezGQIy0CUx3KJ604BjzTm76tPzzPn4aHl5pcjcVicUeVbqLNF
UMQUR4ZqJl29HIFW2XEvMB3aZqjdt4+P/sJOtQARAQABiQElBBgBCAAPBQJY8DFZ
AhsMBQklmAYAAAoJEEnFt53xG7DbFEEH/1K9UnV+tiJgcp6Kch6B6RVa03p6SX0r
OFMW+RsAwDkAlSLfZMrMWJVPZgXdU4EsT4FGYLmL6ZBM2Lo2xZjmilQ8Y477Kmjo
TT0RlcKyD3PEnJ7ufDX53fE5uJsICkIvQoF1dHmftfRC9QX5CmwDF5StCrvK5WYD
ZJYc/360UsBcCxf2WawV/WzNmQ02Iy14Bfd/VYkrLWqDqhDExUlftDf5V4YG7LL/
/0eZwxwOpHJjuQ5NYoT4HNHxCKy70W5s7n8+AWRLrbTIrDRdegglDSeJ0M4zAA9W
ZcKnv216VkD9YtctmZcZRr/C/maBdRjqRDGdHrV4E6pPnT2M459HBsc=
=h7Pp
-----END PGP PUBLIC KEY BLOCK-----
EOF

yum -y install java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel.x86_64 \
    hive-metastore \
    mariadb-connector-java \
    mysql \
    wget \
    unzip \
    jq


cat > /etc/hadoop/conf/core-site.xml << EOF
<configuration>
<property>
  <name>fs.s3.impl</name>
  <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
</property>
<property>
  <name>fs.s3n.impl</name>
  <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
</property>
<property>
  <name>fs.s3a.impl</name>
  <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
</property>
<property>
  <name>fs.AbstractFileSystem.s3.impl</name>
  <value>org.apache.hadoop.fs.s3a.S3A</value>
</property>
<property>
  <name>fs.AbstractFileSystem.s3n.impl</name>
  <value>org.apache.hadoop.fs.s3a.S3A</value>
</property>
<property>
  <name>fs.AbstractFileSystem.s3a.impl</name>
  <value>org.apache.hadoop.fs.s3a.S3A</value>
</property>
<property>
  <name>fs.s3a.connection.ssl.enabled</name>
  <value>true</value>
</property>
<property>
  <name>fs.s3a.server-side-encryption-algorithm</name>
  <value>AES256</value>
</property>
<property>
  <name>fs.s3a.aws.credentials.provider</name>
  <value>com.amazonaws.auth.InstanceProfileCredentialsProvider</value>
</property>
</configuration>
EOF

cat > /etc/hive/conf/hive-site.xml << EOF
<configuration>
<property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>org.mariadb.jdbc.Driver</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://${mysql_db_host}:3306/${mysql_db_name}</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>${mysql_db_username}</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>${mysql_db_password}</value>
</property>
<property>
    <name>datanucleus.fixedDatastore</name>
    <value>true</value>
</property>
<property>
    <name>hive.metastore.uris</name>
    <value>thrift://localhost:9083</value>
</property>
</configuration>
EOF

cat > /etc/hive/conf/hive-env.sh << EOF
export HADOOP_HEAPSIZE=$(cat /proc/meminfo|grep MemTotal|awk '{ printf "%d", $2/1024 * 0.80}')
export HIVE_AUX_JARS_PATH=/usr/share/java/mariadb-connector-java.jar
EOF

#check if database is initialized, test only from rw instances and only if DB is managed by apiary
if [ x"${external_database}" == x"" ] && [ x"${metastore_mode}" == x"readwrite" ]; then
MYSQL_OPTIONS="-h${mysql_db_host} -u${mysql_db_username} -p${mysql_db_password} ${mysql_db_name} -N"
schema_version=`echo "select SCHEMA_VERSION from VERSION"|mysql $MYSQL_OPTIONS`
if [ x"$schema_version" != x"2.3.0" ]; then
    cd /usr/lib/hive/scripts/metastore/upgrade/mysql
    cat hive-schema-2.3.0.mysql.sql|mysql $MYSQL_OPTIONS
    cd /
fi
fi

/sbin/start hive-metastore
