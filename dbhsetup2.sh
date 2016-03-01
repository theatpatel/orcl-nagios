#!/bin/bash
cd /tmp
#wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash
#yum install -y srvadmin-all
cd /etc/snmp
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig
echo 'rocommunity colo.ct' > /etc/snmp/snmpd.conf;
echo 'trapsink  192.168.3.240 colo.ct' >> /etc/snmp/snmpd.conf;
echo 'smuxpeer .1.3.6.1.4.1.674.10892.1' >> /etc/snmp/snmpd.conf;
echo 'pass_persist .1.3.6.1.3.1 /usr/bin/perl /usr/local/bin/iostat-persist.pl' >> /etc/snmp/snmpd.conf;
echo 'disk /' >> /etc/snmp/snmpd.conf;
echo 'disk /u01' >> /etc/snmp/snmpd.conf;
echo 'dontLogTCPWrappersConnects 1'  >> /etc/snmp/snmpd.conf;
echo 'OPTIONS="-Lsd -Lf /dev/null -p /var/run/snmpd.pid"' >> /etc/sysconfig/snmpd.options
sudo /sbin/service dataeng enablesnmp 
/opt/dell/srvadmin/sbin/srvadmin-services.sh restart 
/sbin/chkconfig snmpd on
/etc/rc.d/init.d/snmpd restart
scp 192.168.3.243:/root/scripts/iostat-persist.pl /usr/local/bin/
echo '* * * * * root cd /tmp && iostat -xkd 30 2 | sed 's/,/\./g' > io.tmp && mv io.tmp iostat.cache' > /etc/cron.d/iostat
/sbin/chkconfig ntpd on
/etc/rc.d/init.d/ntpd restart
/usr/sbin/adduser nagios
cd /tmp
wget http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz
gunzip -f nagios-plugins-2.0.3.tar.gz
tar -xf nagios-plugins-2.0.3.tar
rm -f nagios-plugins-2.0.3.tar
cd nagios-plugins-2.0.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install
cd /tmp
rm -rf nagios-plugins-2.0.3/
cd /tmp
wget  http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz?r=http%3A%2F%2Fexchange.nagios.org%2Fdirectory%2FAddons%2FMonitoring-Agents%2FNRPE--2D-Nagios-Remote-Plugin-Executor%2Fdetails&ts=1307917819&use_mirror=surfnet
echo 'sleeping 10 seconds' > /dev/stderr
sleep 10
gunzip -f nrpe-2.15.tar.gz
tar -xf nrpe-2.15.tar
rm -f nrpe-2.15.tar
cd nrpe-2.15
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make all
make install-plugin
make install-xinetd
make install-daemon
make install-daemon-config
cd /tmp
rm -rf nrpe-2.15/
sed -i 's/127.0.0.1/127.0.0.1 192.168.5.10 192.168.3.240 192.168.3.243/' /etc/xinetd.d/nrpe
sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,192.168.5.10,192.168.3.240,192.168.3.243/' /usr/local/nagios/etc/nrpe.cfg
echo 'nrpe            5666/tcp                        # Nagios NRPE' >> /etc/services
/sbin/service xinetd restart
echo 'nagios ALL=(root) NOPASSWD: /usr/local/nagios/libexec/* *' >> /etc/sudoers
#echo 'Password for oracle user' > /dev/stderr
#passwd oracle
#echo 'password for oracle vnc'
#/usr/bin/vncpasswd /home/oracle/.vnc/passwd
#echo 'password for root vnc'
#/usr/bin/vncpasswd /root/.vnc/passwd
#chown oracle:dba /u01
#chown oracle:oinstall /home/oracle/.vnc/xstartup
#chmod 755 /home/oracle/.vnc/xstartup
#chmod 755 /root/.vnc/xstartup
echo '########################################################################'
echo 'working for you....Firewall...setting rules and stuff..................'
echo '########################################################################'
iptables -I RH-Firewall-1-INPUT -p tcp -m tcp --dport 5666 -j ACCEPT
service iptables save
echo '########################################################################'
service iptables restart
echo 'Added rules....'
echo '########################################################################'
echo 'nrpe            5666/tcp                        # Nagios NRPE' >> /etc/services
/sbin/service xinetd restart
echo '########################################################################'
echo 'Listing new rules below'
echo 'How do they look? '
echo '########################################################################'
iptables -L
echo '########################################################################'
echo ' This should be compelted now....'
echo '########################################################################'
