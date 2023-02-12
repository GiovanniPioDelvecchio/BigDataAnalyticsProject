# downloading dos2unix to convert text files from dos format (with \r\n as newline char)
# to unix format.
sudo apt install dos2unix
echo "switching user to ubuntu"
sudo -i -u ubuntu bash << EOF
# copy rsa key to the appropriate vagrant shared folder
echo "trying to copy ssh key"
cp /home/ubuntu/.ssh/id_rsa.pub /vagrant/ssh-keys/
EOF
# delete the line of the hosts file containing the ip associated to "master"
echo "deleting the line containing master in the hosts file"
sed -i '/master/d' /etc/hosts
sed -i '/worker1/d' /etc/hosts

# add the line where we create the alias 'master' for the ip of the master
echo "adding the line about the chosen master ip in the hosts file"
echo '192.168.33.10 master' >> /etc/hosts

# add the line where we create the alias 'worker1' for the ip of the worker1
echo "adding the line about the chosen worker ip in the hosts file"
echo '192.168.33.11 worker1' >> /etc/hosts

# copying hadoop and yarn configuration files
echo "copying configuration files"
dos2unix /vagrant/config-files/core-site.xml
dos2unix /vagrant/config-files/hdfs-site-1.xml
dos2unix /vagrant/config-files/yarn-site-2.xml
dos2unix /vagrant/config-files/mapred-site.xml
dos2unix /vagrant/config-files/workers
cat /vagrant/config-files/core-site.xml > /usr/local/hadoop-3.3.4/etc/hadoop/core-site.xml
cat /vagrant/config-files/hdfs-site-1.xml > /usr/local/hadoop-3.3.4/etc/hadoop/hdfs-site.xml
cat /vagrant/config-files/yarn-site-2.xml > /usr/local/hadoop-3.3.4/etc/hadoop/yarn-site.xml
cat /vagrant/config-files/mapred-site.xml > /usr/local/hadoop-3.3.4/etc/hadoop/mapred-site.xml
cat /vagrant/config-files/workers > /usr/local/hadoop-3.3.4/etc/hadoop/workers

# add the changes to hadoop-env.sh
if ! grep -q 'export HDFS_NAMENODE_USER=ubuntu' /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh; then
	echo 'export HDFS_NAMENODE_USER=ubuntu' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh
fi

if ! grep -q 'export HDFS_DATANODE_USER=ubuntu' /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh; then
	echo 'export HDFS_DATANODE_USER=ubuntu' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh
fi

if ! grep -q 'export HDFS_SECONDARYNAMENODE_USER=ubuntu' /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh; then
	echo 'export HDFS_SECONDARYNAMENODE_USER=ubuntu' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh
fi

if ! grep -q 'export YARN_RESOURCEMANAGER_USER=ubuntu' /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh; then
	echo 'export YARN_RESOURCEMANAGER_USER=ubuntu' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh
fi

if ! grep -q 'export YARN_NODEMANAGER_USER=ubuntu' /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh; then
	echo 'export YARN_NODEMANAGER_USER=ubuntu' >> /usr/local/hadoop-3.3.4/etc/hadoop/hadoop-env.sh
fi


# Add spark path to .profile file in ubuntu:
sudo -i -u ubuntu bash << EOF
if ! grep -q 'PATH=/usr/local/spark-3.3.1-bin-hadoop3/bin:\$PATH' /home/ubuntu/.profile; then
	sudo sed -i '9i PATH=/usr/local/spark-3.3.1-bin-hadoop3/bin:\$PATH' /home/ubuntu/.profile
	echo "added spark path in /home/ubuntu/.profile file"
fi
if ! grep -q 'export HADOOP_CONF_DIR=/usr/local/hadoop-3.3.4/etc/hadoop/' /home/ubuntu/.profile; then
	sudo sed -i '10i export HADOOP_CONF_DIR=/usr/local/hadoop-3.3.4/etc/hadoop/' /home/ubuntu/.profile
	echo "added HADOOP_CONF_DIR in /home/ubuntu/.profile file"
fi
if ! grep -q 'export SPARK_HOME=/usr/local/spark-3.3.1-bin-hadoop3/' /home/ubuntu/.profile; then
	sudo sed -i '11i export SPARK_HOME=/usr/local/spark-3.3.1-bin-hadoop3/' /home/ubuntu/.profile
	echo "added SPARK_HOME in /home/ubuntu/.profile file"
fi
if ! grep -q 'export LD_LIBRARY_PATH=/usr/local/hadoop-3.3.4/lib/native:\$LD_LIBRARY_PATH' /home/ubuntu/.profile; then
	sudo sed -i '12i export LD_LIBRARY_PATH=/usr/local/hadoop-3.3.4/lib/native:\$LD_LIBRARY_PATH' /home/ubuntu/.profile
	echo "added LD_LIBRARY_PATH in /home/ubuntu/.profile file"
fi
EOF

mv /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf.template /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf

if ! grep -q 'spark.master    yarn' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf; then
	sudo sed -i '1i spark.master    yarn' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
	echo "added spark.master in spark-defaults.conf"
fi

if ! grep -q 'spark.driver.memory    512m' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf; then
	sudo sed -i '2i spark.driver.memory    512m' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
	echo "set spark driver memory to 512m in spark-defaults.conf"
fi

if ! grep -q 'spark.yarn.am.memory    512m' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf; then
	sudo sed -i '3i spark.yarn.am.memory    512m' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
	echo "set spark yarn am memory to 512m in spark-defaults.conf"
fi

if ! grep -q 'spark.executor.memory          512m' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf; then
	sudo sed -i '4i spark.executor.memory          512m' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
	echo "set executor memory to 512m in spark-defaults.conf"
fi

# ./hdfs dfs -mkdir hdfs://master:9000/jar-archives

# /usr/local/spark-3.3.1-bin-hadoop3/spark-libs.jar

# ./hdfs dfs -put /usr/local/spark-3.3.1-bin-hadoop3/spark-libs.jar /jar-archives

if ! grep -q 'spark.yarn.jars hdfs://master:9000/jar-archives/spark-libs.jar' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf; then
	sudo sed -i 'spark.yarn.jars hdfs://master:9000/jar-archives/spark-libs.jar' /usr/local/spark-3.3.1-bin-hadoop3/conf/spark-defaults.conf
	echo "set jar location in hdfs"
fi


# to run a spark job, log in ubuntu with sudo su -l ubuntu, navigate to $SPARK_HOME and submit the job from
# there with the "submit" command, i.e. spark-submit --deploy-mode cluster /vagrant/spark-test-scripts/pi.py

# while being logged as ubuntu, cd into "/" and run start-all.sh

# open jupyter notebook with: jupyter notebook --no-browser --ip 0.0.0.0 and pasting the url in the browser
# after substituting "master" with "192.168.33.10".
# Now it is possible to run spark on a jupyter notebook (install findspark using "!pip install findspark",
# then import it using "import findspark" and then call "findspark.init()")

