# About

This is an Ansible Playbook to deploy data lab environments with any number of
tools commonly used by by data driven organizations. The purpose of the playbook
is to accelerate the deployment of data labs, enforcing consistency across labs,
for functional and performance testing.

The configurations are tuned to fit bare deploy mode and without S3A support.

Post deploy, the following software will be available inside the data lab:

* Hadoop 2.7.3
* Spark 2.1.1
* Hive 2.2.1
* Presto 0.177

# Dependencies

This playbook depends on the "oracle-java" playbook, you will need to install
it from Ansible Galaxy. You can do this by running this command, assuming you
have Ansible installed.

```sudo ansible-galaxy install ansiblebit.oracle-java```

# Provision Data Lab on Bare Metal

If you decide to deploy to bare metal servers, the current assumption is that
they are provisioned running Red Hat Enterprise Linux. Distributions like
CentOS may work, but haven't been tested.

When you deploy to bare metal, you need to specify which group a particular
node will assume in an Ansible inventory file. There are two main host groups
for this playbook, with an example inventory named ``hosts`` in the root of the
playbook repository.

You should change the deploy_method variable in the ``group_vars/all`` file to
``bare``.

Once you have added your hosts to the inventory file, you can run the site
play:

```ansible-playbook -i hosts site.yml```

When it finishes, you should have a complete data lab ready to go!

# Deployed Environment

* master 
* core

The "master" host runs cluster services, and serve as a client bastion to launch
benchmarks from. You should only have one "master" host in your cluster.

* yarn resource manager
* yarn history server
* hdfs namenode
* hive metastore
* presto coordinator

The "core" hosts do the heavy lifting, running map reduce or spark tasks on
yarn, or processing queries on presto workers.

* yarn node manager
* hdfs datanode
* kafka broker
* presto worker


# Reminders
* If you have problems downloading packages, you can download them manually and place them at a direction which you need to specify as ```tarball_prefix``` in ```./var/resources.yml

* ```hive metastore warehouse``` and ```hive scratch direction```
Please specify these two directions in ```./group_vars/all``` 

* Build failure with /hadoop-home/hive-testbench/tpcds-build.sh
If the error is due to connection time out to repo.maven.apache.org, please add one proxy server which can access that url in ./maven/conf/settings.conf, proxy section.

* Hive-testbench
Please first run ```tpcds-build.sh``` , then ```tpcds-setup.sh``` to generate data, and ```tpcds-run.sh``` for benchmarking. Please check the details in ```/hadoop-home/hive-testbench/README.md```.



