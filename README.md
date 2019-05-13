# Openshift_Vmware

To deploy an openshift infrastructure with 3 masters(infra + etcd) , 3 nodes and Load balancing on local you will find the configuration of the automated installion in the folder openshift-aws 
Clone the project and just run the playbook install_nodemaster_tools.yml under the folder automated_installation.
The ldapjinja2.j2 is used to connect the openshift plateform with an LDAP server. 
For the monitoring tools ( prometheus and graphana ) the configuration steps arez listed in monitoring_file. 


# Openshift_AWS
Now for the deployment of openshift on top of aws :
 * the first step is to create a personalised ami images using packer that contains the most of tools needed to install the cluster like docker ...
 * the second is to to provision the infrastructure with the terraform script ( 3 masters , 3 nodes , 3 infra and ALB ).
 * Create an iam role and attach it to the instances to allow them to use the S3 service of AWS.
 * finally clone the repository and install the cluster.
