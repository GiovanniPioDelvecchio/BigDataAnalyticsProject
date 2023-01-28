# TODO: add master.sh and worker.sh in the provision pipeline
# execute this after master.sh and worker.sh have been executed
# on the respective nodes

# the execution of this script must be performed on the master
# it is a quick way to start Hadoop and Yarn after formatting
# the distributed file system

# quick check if the worker is reachable
sudo -i -u ubuntu bash << EOF
ssh worker1
exit
echo "connection with the worker established"
echo "ssh out of the worker"
EOF

sudo -i -u ubuntu bash << EOF
echo "now in ubuntu"
echo "removing previously created hdfs"
sudo rm -r ~/hdfs
EOF

echo "creating a brand new hdfs"
sudo /usr/local/hadoop-3.3.4/bin/hdfs namenode -format

echo "starting dfs and yarn"
sudo /usr/local/hadoop-3.3.4/sbin/start-dfs.sh
sudo /usr/local/hadoop-3.3.4/sbin/start-yarn.sh

