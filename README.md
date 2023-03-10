# BigDataAnalyticsProject
Repository for the Big Data Analytics project.
Developed by Giovanni Pio Delvecchio.

The repository contains all the files needed to set up a fully distributed local cluster with Hadoop, Yarn and Spark. 

The project consists in a task of binary classification over a dataset containing data about credit card clients, essentially replicating the
results presented in the paper "The comparisons of data mining techniques for the predictive accuracy of probability of default of credit card clients" 
by I-Cheng Yeh and Che-hui Lien, in a fully distributed setting created with with Hadoop, Yarn and PySpark.
The results related to all the methods can be found in the notebook CreditCardClients.ipynb, while the results related to the
Linear Discriminant Analysis classifier are presentend more in detail in the corresponding notebook (LinearDiscriminantAnalysis.ipynb).
The methods presented here and in the reference paper are:
- Multi-layer Perceptron
- Logistic Regression
- Decision Tree
- Naive Bayes
- Approximated KNN (sample of a balanced portion of the dataset, approximately 400 examples, used to perform KNN in a distributed setting)
- Linear Discriminant Analysis (performed over partitions of different sizes of the dataset, read from the HDFS, since PySpark
                                does not include an implementation of LDA)

Requirements: 
- Vagrant 2.3.4       
- VirtualBox 7.0.6
- Spark 3.3.1 (download spark-3.3.1-bin-hadoop3.tgz from https://archive.apache.org/dist/spark/spark-3.3.1/ and place it in the root directory)

Structure of the repository:
```
C:.
|   bootstrap.sh                        # bootstrap file needed for provisioning, it has been modified since the download of Spark-3.3.1 was broken
|   CreditCardClients.ipynb             # Main notebook containing the analysis for DM method
|   default of credit card clients.xls  # dataset file
|   eventLogs-fullnotebook.zip          # logs related to the execution of the main notebook
|   eventLogs-LDA.zip                   # logs related to the execution of the notebook related to the LDA analysis
|   LinearDiscriminantAnalysis.ipynb    # more in depth analysis of the LDA DM method
|   README.md                           
|   spark-3.3.1-bin-hadoop3.tgz         # file that has to be downloaded and added to the folder in order to correctly set up the environment
|   Vagrantfile                         # Vagrant file containing the specifications of each virtual machine
|
+---.ipynb_checkpoints 
|       CreditCardClients-checkpoint.ipynb 
|       LinearDiscriminantAnalysis-checkpoint.ipynb 
|
+---.vagrant
|   +---machines
|      +---master
|      |
|      |
|      \---worker1
|         
+---config-files
|       core-site.xml
|       hdfs-site-1.xml # this is actually used, the alternative hdfs-site has been 
|                       # created in order to test the configuration on the slides
|       hdfs-site-2.xml
|       mapred-site.xml
|       workers
|       yarn-site-1.xml 
|       yarn-site-2.xml # this is actually used, the alternative yarn-site has been created 
|                       # in order to test the configuration on the slides
|
+---scripts
|       master.sh       # script needed in order to set up the config files of the master node
|       remove-hdfs.sh  # script needed in order to delete the folder "hdfs" of a worker before 
|                       # formatting the hdfs with start-dfs-rm.sh
|       start-all.sh    # script needed to start Hadoop, Yarn and the Spark history server.
|       start-dfs-rm.sh # script needed to check if the worker node is connected and format the HDFS, 
|                       # it also contains the additional
|                       # commands that have to be run as logged with the ubuntu user, 
|                       # in order to start correctly the Spark history server
|                       # and launch Jupyter Notebook
|       stop-all.sh     # script needed to stop the History Server, Yarn and Hadoop
|       worker.sh       # script needed in order to set up the config files of the worker node
|
+---serialized          # folder containing the serialized versions of the dataset 
|                       # after different preprocessing steps
|       mm_scaled_test_schema.json
|       mm_scaled_train_schema.json
|       test_cred_schema.json
|       train_cred_schema.json
|       vectorized_positive_test_schema.json
|       vectorized_positive_train_schema.json
|       vectorized_scaled_test_schema.json
|       vectorized_scaled_train_schema.json
|
+---spark-test-scripts  # folder containing the file used to test if a program can be submitted 
|                       # with the spark submit command
|       pi.py
|
+---ssh-keys            # folder containing the ssh keys needed in order to allow the connection 
|                       # between the master and the worker
|       id_rsa.pub
|
\---train_partitions    # folder containing the partitioned version of the dataset, 
                        # which are needed in the LinearDiscriminantAnalysis.ipynb notebook
        partition_0_schema.json
        partition_1_schema.json
        partition_2_schema.json
        train_split_0.json
        train_split_1.json
        train_split_2.json
```

### How to set up the cluster for the first time:
Run the following commands in cmd or PowerShell after satisfying the above mentioned requirements 
(the commands must be executed after navigating to the root directory):
```
- vagrant up --provisions
- vagrant ssh master
- cd / 
- sudo apt install dos2unix
- dos2unix /vagrant/scripts/master.sh
- sudo /vagrant/scripts/master.sh
- exit (or, open another tab in the shell)
- vagrant ssh worker1
- dos2unix /vagrant/scripts/worker.sh
- sudo /vagrant/scripts/worker.sh
- exit (or go back to the tab where there is the master)
- dos2unix /vagrant/scripts/start-dfs-rm.sh
- sudo /vagrant/scripts/start-dfs-rm.sh
- /usr/local/hadoop-3.3.4/bin/hdfs dfs -mkdir /spark-logs
```

### How to run the cluster all the other times:
```
- vagrant up master
- vagrant up worker1
- vagrant ssh master
- cd /
- sudo /vagrant/scripts/start-all.sh
```

### What next:
check if the nodes are connected by pasting "192.168.33.10:9870" in a browser.
Start the Spark History Server with:
```
sudo su -l ubuntu
sudo /usr/local/spark-3.3.1-bin-hadoop3/sbin/start-history-server.sh
```

Launch jupyter notebook with:
```
jupyter notebook --no-browser --ip 0.0.0.0
```
paste the jupyter url from the CLI in a browser and substitute "master" with "192.168.33.10".
Open the notebooks and run the desired cells.
