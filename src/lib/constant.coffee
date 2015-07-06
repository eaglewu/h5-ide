define ['MC', 'i18n!/nls/lang.js'], ( MC, lang ) ->

    wrap = ( dict ) ->
        wrapArray = _.isArray(dict)
        if wrapArray then wrappedDict = [] else wrappedDict = {}

        _.each dict, ( name, key ) ->
            if wrapArray
                wrappedDict.push RESTYPE[ name ]
            else
                wrappedDict[ RESTYPE[ key ] ] = name
            null

        wrappedDict

    AWS_RESOURCE_KEY =
        "AWS.EC2.AvailabilityZone"                  : "ZoneName"
        "AWS.EC2.Instance"                          : "InstanceId"
        "AWS.EC2.KeyPair"                           : "KeyName"
        "AWS.EC2.SecurityGroup"                     : "GroupId"
        "AWS.EC2.EIP"                               : "PublicIp"
        "AWS.EC2.AMI"                               : "ImageId"
        "AWS.EC2.EBS.Volume"                        : "VolumeId"
        "AWS.ELB"                                   : "LoadBalancerName"
        "AWS.VPC.VPC"                               : "VpcId"
        "AWS.VPC.Subnet"                            : "SubnetId"
        "AWS.VPC.InternetGateway"                   : "InternetGatewayId"
        "AWS.VPC.RouteTable"                        : "RouteTableId"
        "AWS.VPC.VPNGateway"                        : "VpnGatewayId"
        "AWS.VPC.CustomerGateway"                   : "CustomerGatewayId"
        "AWS.VPC.NetworkInterface"                  : "NetworkInterfaceId"
        "AWS.VPC.DhcpOptions"                       : "DhcpOptionsId"
        "AWS.VPC.VPNConnection"                     : "VpnConnectionId"
        "AWS.VPC.NetworkAcl"                        : "NetworkAclId"
        "AWS.IAM.ServerCertificate"                 : ""
        "AWS.AutoScaling.Group"                     : "AutoScalingGroupARN"
        "AWS.AutoScaling.LaunchConfiguration"       : "LaunchConfigurationARN"
        "AWS.AutoScaling.NotificationConfiguration" : ""
        "AWS.AutoScaling.ScalingPolicy"             : "PolicyARN"
        "AWS.AutoScaling.ScheduledActions"          : "ScheduledActionARN"
        "AWS.CloudWatch.CloudWatch"                 : "AlarmArn"
        "AWS.SNS.Subscription"                      : ""
        "AWS.SNS.Topic"                             : "TopicArn"
        "AWS.RDS.DBSubnetGroup"                     : "DBSubnetGroupName"
        "AWS.RDS.DBInstance"                        : "DBInstanceIdentifier"
        "AWS.RDS.OptionGroup"                       : "OptionGroupName"

    # A short version
    RESTYPE =
        # AWS RESOURCE
        AZ           : "AWS.EC2.AvailabilityZone"
        INSTANCE     : "AWS.EC2.Instance"
        KP           : "AWS.EC2.KeyPair"
        SG           : "AWS.EC2.SecurityGroup"
        EIP          : "AWS.EC2.EIP"
        AMI          : "AWS.EC2.AMI"
        VOL          : "AWS.EC2.EBS.Volume"
        SNAP         : "AWS.EC2.EBS.Snapshot"
        ELB          : "AWS.ELB"
        VPC          : "AWS.VPC.VPC"
        SUBNET       : "AWS.VPC.Subnet"
        IGW          : "AWS.VPC.InternetGateway"
        RT           : "AWS.VPC.RouteTable"
        VGW          : "AWS.VPC.VPNGateway"
        CGW          : "AWS.VPC.CustomerGateway"
        ENI          : "AWS.VPC.NetworkInterface"
        DHCP         : "AWS.VPC.DhcpOptions"
        VPN          : "AWS.VPC.VPNConnection"
        ACL          : "AWS.VPC.NetworkAcl"
        IAM          : "AWS.IAM.ServerCertificate"
        ASG          : 'AWS.AutoScaling.Group'
        LC           : 'AWS.AutoScaling.LaunchConfiguration'
        NC           : 'AWS.AutoScaling.NotificationConfiguration'
        SP           : 'AWS.AutoScaling.ScalingPolicy'
        SA           : 'AWS.AutoScaling.ScheduledActions'
        CW           : 'AWS.CloudWatch.CloudWatch'
        SUBSCRIPTION : 'AWS.SNS.Subscription'
        TOPIC        : 'AWS.SNS.Topic'
        TAG          : 'AWS.EC2.Tag'
        ASGTAG       : 'AWS.AutoScaling.Tag'

        DBSBG        : 'AWS.RDS.DBSubnetGroup'
        DBINSTANCE   : 'AWS.RDS.DBInstance'
        DBPARAM      : 'AWS.RDS.Parameter'
        DBPG         : 'AWS.RDS.ParameterGroup'
        DBSNAP       : 'AWS.RDS.Snapshot'
        DBES         : 'AWS.RDS.EventSubscription'
        DBOG         : 'AWS.RDS.OptionGroup'
        DBENGINE     : 'AWS.RDS.DBEngineVersion'

        # Openstack Resource
        OSSERVER   : "OS::Nova::Server"
        OSNETWORK  : "OS::Neutron::Network"
        OSSUBNET   : "OS::Neutron::Subnet"
        OSPORT     : "OS::Neutron::Port"
        OSSG       : "OS::Neutron::SecurityGroup"
        OSSGRULE   : "OS::Neutron::SecurityGroupRule"
        OSRT       : "OS::Neutron::Router"
        OSFIP      : "OS::Neutron::FloatingIP"
        OSELB      : "OS::Elb"  # Custom type, there's no such type in openstack
        OSLISTENER : "OS::Neutron::VIP"
        OSPOOL     : "OS::Neutron::Pool"
        OSHM       : "OS::Neutron::HealthMonitor"
        OSVOL      : "OS::Cinder::Volume"
        OSFLAVOR   : "OS::Nova::Flavor"
        OSKP       : "OS::Nova::KeyPair"
        OSIMAGE    : "OS::Image"
        OSSNAP     : "OS::Snapshot"
        OSNQ       : "OS::Neutron::Quota"
        OSCQ       : "OS::Cinder::Quota"

        # Marathon
        MRTHAPP    : "DOCKER.MARATHON.App"
        MRTHGROUP  : "DOCKER.MARATHON.Group"
        DOCKERIMAGE: "DOCKER.IMAGE"

        # Mesos
        MESOSMASTER: "MESOS.MASTER"
        MESOSSLAVE : "MESOS.SLAVE"
        MESOSASG   : "MESOS.ASG"
        MESOSLC    : "MESOS.LC"

    RESNAME =
        AZ           : "Availability Zone"
        INSTANCE     : "Instance"
        KP           : "Key Pair"
        SG           : "Security Group"
        EIP          : "Elastic IP"
        AMI          : "AMI"
        VOL          : "Volume"
        SNAP         : "Snapshot"
        ELB          : "Load Balancer"
        VPC          : "VPC"
        SUBNET       : "Subnet"
        IGW          : "Internet Gateway"
        RT           : "Route Table"
        VGW          : "VPN Gateway"
        CGW          : "Customer Gateway"
        ENI          : "Network Interface"
        DHCP         : "Dhcp Options"
        VPN          : "VPN Connection"
        ACL          : "Network Acl"
        IAM          : "Server Certificate"
        ASG          : 'AutoScaling Group'
        LC           : 'Launch Configuration'
        NC           : 'Notification Configuration'
        SP           : 'Scaling Policy'
        SA           : 'Scheduled Actions'
        CW           : 'Cloud Watch'
        SUBSCRIPTION : 'Subscription'
        TOPIC        : 'Topic'

        DBSBG        : 'DB Subnet Group'
        DBINSTANCE   : 'DB Instance'
        DBPARAM      : 'Parameter'
        DBPG         : 'ParameterGroup'
        DBSNAP       : 'DB Snapshot'
        DBES         : 'Event Subscription'
        DBOG         : 'OptionGroup'
        DBENGINE     : 'DB Engine Version'

        OSSERVER     : "Server"
        OSNETWORK    : "Network"
        OSSUBNET     : "Subnet"
        OSPORT       : "Port"
        OSSG         : "Security Group"
        OSSGRULE     : "Security Group Rule"
        OSRT         : "Router"
        OSFIP        : "Floating IP"
        OSELB        : "Load Balancer"
        OSLISTENER   : "Listener"
        OSPOOL       : "Pool"
        OSHM         : "Health Monitor"
        OSVOL        : "Volume"
        OSFLAVOR     : "Flavor"
        OSKP         : "Key Pair"
        OSIMAGE      : "Image"
        OSSNAP       : "Snapshot"


    HASTAG = [
        'CGW'
        'DHCP'
        'AMI'
        'INSTANCE'
        'IGW'
        'ACL'
        'ENI'
        'RT'
        'SG'
        'SNAP'
        'SUBNET'
        'VOL'
        'VPC'
        'VPN'
        'ASG'
        'DBINSTANCE'
        'DBSNAP'
        'DBOG'
        'DBPG'
        'DBSBG'
    ]



    #private
    AWS_RESOURCE_SHORT_TYPE =
        AWS_EC2_AvailabilityZone  : "az"
        AWS_EC2_Instance          : "instance"
        AWS_EC2_KeyPair           : "kp"
        AWS_EC2_SecurityGroup     : "sg"
        AWS_EC2_EIP               : "eip"
        AWS_EC2_AMI               : "ami"
        AWS_EBS_Volume            : "vol"
        AWS_EBS_Snapshot          : "snap"
        AWS_ELB                   : "elb"
        AWS_VPC_VPC               : "vpc"
        AWS_VPC_Subnet            : "subnet"
        AWS_VPC_InternetGateway   : "igw"
        AWS_VPC_RouteTable        : "rtb"
        AWS_VPC_VPNGateway        : "vgw"
        AWS_VPC_CustomerGateway   : "cgw"
        AWS_VPC_NetworkInterface  : "eni"
        AWS_VPC_DhcpOptions       : "dhcp"
        AWS_VPC_VPNConnection     : "vpn"
        AWS_VPC_NetworkAcl        : "acl"
        AWS_IAM_ServerCertificate : "iam"
        #
        AWS_AutoScaling_Group                     : 'asg'
        AWS_AutoScaling_LaunchConfiguration       : 'asl_lc'
        AWS_AutoScaling_NotificationConfiguration : 'asl_nc'
        AWS_AutoScaling_ScalingPolicy             : 'asl_sp'
        AWS_AutoScaling_ScheduledActions          : 'asl_sa'
        AWS_CloudWatch_CloudWatch                 : 'clw'
        AWS_SNS_Subscription                      : 'sns_sub'
        AWS_SNS_Topic                             : 'sns_top'


    DB_INSTANCECLASS = [
      { instanceClass: "db.t1.micro"    , cpu: "1 vCPU", memory: '0.613 GB', ebs: false, ecu: 1 }
      { instanceClass: "db.t2.micro"    , cpu: "1 vCPU", memory: '1 GB', ebs: false, ecu: 1 }
      { instanceClass: "db.t2.small"    , cpu: "1 vCPU", memory: '2 GB', ebs: false, ecu: 1 }
      { instanceClass: "db.t2.medium"   , cpu: "2 vCPU", memory: '4 GB', ebs: false, ecu: 2 }
      { instanceClass: "db.m1.small"    , cpu: "1 vCPU", memory: '1.7 GB', ebs: false, ecu: 1 }
      { instanceClass: "db.m1.medium"   , cpu: '1 vCPU', memory: '3.75 GB', ebs: false, ecu: 2 }
      { instanceClass: "db.m1.large"    , cpu: '2 vCPU', memory: '7.5 GB', ebs: true, ecu: 4 }
      { instanceClass: "db.m1.xlarge"   , cpu: '4 vCPU', memory: '15 GB', ebs: true, ecu: 8 }
      { instanceClass: "db.m2.xlarge"   , cpu: '2 vCPU', memory: '17.1 GB', ebs: false, ecu: 6.5 }
      { instanceClass: "db.m2.2xlarge"  , cpu: '4 vCPU', memory: '34 GB', ebs: true, ecu: 13 }
      { instanceClass: "db.m2.4xlarge"  , cpu: '8 vCPU', memory: '68 GB', ebs: true, ecu: 26 }
      { instanceClass: "db.cr1.8xlarge" , cpu: '32 vCPU', memory: '244 GB', ebs: false, ecu: 88 }
      { instanceClass: "db.m3.medium"   , cpu: '1 vCPU', memory: '3.75 GB', ebs: false, ecu: 3 }
      { instanceClass: "db.m3.large"    , cpu: '2 vCPU', memory: '7.5 GB', ebs: false, ecu: 6.5 }
      { instanceClass: "db.m3.xlarge"   , cpu: '4 vCPU', memory: '15 GB', ebs: true, ecu: 13 }
      { instanceClass: "db.m3.2xlarge"  , cpu: '8 vCPU', memory: '30 GB', ebs: true, ecu: 26 }
      { instanceClass: "db.r3.large"    , cpu: '2 vCPU', memory: '15 GB', ebs: false, ecu: 6.5 }
      { instanceClass: "db.r3.xlarge"   , cpu: '4 vCPU', memory: '30.5 GB', ebs: true, ecu: 13 }
      { instanceClass: "db.r3.2xlarge"  , cpu: '8 vCPU', memory: '61 GB', ebs: true, ecu: 26 }
      { instanceClass: "db.r3.4xlarge"  , cpu: '16 vCPU', memory: '122 GB', ebs: true, ecu: 52 }
      { instanceClass: "db.r3.8xlarge"  , cpu: '32 vCPU', memory: '244GB', ebs: false, ecu: 104 }
    ]

    DB_ENGINE =
        MYSQL     : "mysql"
        ORA_SE1   : "oracle-se1"
        ORA_SE    : "oracle-se"
        ORA_EE    : "oracle-ee"
        SQLSRV_EE : "sqlserver-ee"
        SQLSRV_SE : "sqlserver-se"
        SQLSRV_EX : "sqlserver-ex"
        SQLSRV_WEB: "sqlserver-web"
        POSTGRES  : "postgres"

    DB_ENGINTYPE =
        'mysql'         : "mysql"
        'oracle-ee'     : "oracle"
        'oracle-se'     : "oracle"
        'oracle-se1'    : "oracle"
        'sqlserver-ee'  : "sqlserver"
        'sqlserver-ex'  : "sqlserver"
        'sqlserver-se'  : "sqlserver"
        'sqlserver-web' : "sqlserver"
        'postgres'      : "postgresql"

    DB_ENGINE_ARY =
        'mysql'         : ["mysql"]
        'oracle'        : ['oracle-ee', 'oracle-se', 'oracle-se1']
        'sqlserver'     : ['sqlserver-ee', 'sqlserver-ex', 'sqlserver-se', 'sqlserver-web']
        'postgres'      : ['postgres']

    DB_DEFAULTSETTING =
      'mysql'           : { port: 3306, dbname: '', charset: '', allocatedStorage: 5 }
      'postgres'        : { port: 5432, dbname: '', charset: '', allocatedStorage: 5 }
      'oracle-ee'       : { port: 1521, dbname: 'ORCL', charset: 'AL32UTF8', allocatedStorage: 10 }
      'oracle-se'       : { port: 1521, dbname: 'ORCL', charset: 'AL32UTF8', allocatedStorage: 10 }
      'oracle-se1'      : { port: 1521, dbname: 'ORCL', charset: 'AL32UTF8', allocatedStorage: 10 }
      'sqlserver-ee'    : { port: 1433, dbname: '', charset: '', allocatedStorage: 200 }
      'sqlserver-ex'    : { port: 1433, dbname: '', charset: '', allocatedStorage: 30 }
      'sqlserver-se'    : { port: 1433, dbname: '', charset: '', allocatedStorage: 200 }
      'sqlserver-web'   : { port: 1433, dbname: '', charset: '', allocatedStorage: 30 }

    INSTANCE_STATES =
        'pending'      : 0
        'running'      : 16
        'shuttingdown' : 32
        'terminated'   : 48
        'stopping'     : 64
        'stopped'      : 80


    #private
    MESSAGE_E =
        MESSAGE_E_SESSION  : lang.SERVICE.CONSTANT_MSG_E_SESSION
        MESSAGE_E_EXTERNAL : lang.SERVICE.CONSTANT_MSG_E_EXTERNAL
        MESSAGE_E_ERROR    : lang.SERVICE.CONSTANT_MSG_E_ERROR
        MESSAGE_E_UNKNOWN  : lang.SERVICE.CONSTANT_MSG_E_UNKNOW
        MESSAGE_E_PARAM    : lang.SERVICE.CONSTANT_MSG_E_PARAM


    #private
    REGION_KEYS = [
        # # aws
        'us-east-1'
        'us-west-1'
        'us-west-2'
        'eu-west-1'
        'eu-central-1'
        'ap-southeast-1'
        'ap-southeast-2'
        'ap-northeast-1'
        'sa-east-1'
        # # openstack - awcloud
        # 'guangzhou'
        # 'beijing'
        # 'cn-north-1'
    ]

    #private
    REGION_LABEL =
        # # aws
        'us-east-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_us-east-1']
        'us-west-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_us-west-1']
        'us-west-2'      : lang.IDE[ 'IDE_LBL_REGION_NAME_us-west-2']
        'eu-west-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_eu-west-1']
        'eu-central-1'   : lang.IDE[ 'IDE_LBL_REGION_NAME_eu-central-1']
        'ap-southeast-2' : lang.IDE[ 'IDE_LBL_REGION_NAME_ap-southeast-2']
        'ap-northeast-1' : lang.IDE[ 'IDE_LBL_REGION_NAME_ap-northeast-1']
        'ap-southeast-1' : lang.IDE[ 'IDE_LBL_REGION_NAME_ap-southeast-1']
        'sa-east-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_sa-east-1']
        # # openstack - awcloud
        # 'guangzhou'      : lang.IDE[ 'IDE_LBL_REGION_NAME_guangzhou']
        # 'beijing'        : lang.IDE[ 'IDE_LBL_REGION_NAME_beijing']
        # 'cn-north-1'     : lang.IDE[ 'IDE_LBL_REGION_NAME_cn-north-1' ]

    REGION_SHORT_LABEL =
        # # aws
        'us-east-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_us-east-1']
        'us-west-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_us-west-1']
        'us-west-2'      : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_us-west-2']
        'eu-west-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_eu-west-1']
        'eu-central-1'   : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_eu-central-1']
        'ap-southeast-1' : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_ap-southeast-1']
        'ap-southeast-2' : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_ap-southeast-2']
        'ap-northeast-1' : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_ap-northeast-1']
        'sa-east-1'      : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_sa-east-1']
        # # openstack - awcloud
        # 'guangzhou'      : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_guangzhou']
        # 'beijing'        : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_beijing']
        # 'cn-north-1'     : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_cn-north-1']

    #private
    RETURN_CODE =
        E_OK           : 0
        E_NONE         : 1
        E_INVALID      : 2
        E_FULL         : 3
        E_EXIST        : 4
        E_EXTERNAL     : 5
        E_FAILED       : 6
        E_BUSY         : 7
        E_NORSC        : 8
        E_NOPERM       : 9
        E_NOSTOP       : 10
        E_NOSTART      : 11
        E_ERROR        : 12
        E_LEFTOVER     : 13
        E_TIMEOUT      : 14
        E_UNKNOWN      : 15
        E_CONN         : 16
        E_EXPIRED      : 17
        E_PARAM        : 18
        E_SESSION      : 19
        E_END          : 20
        E_BLOCKED_USER : 21

    #private
    OPS_STATE =
        PENDING   : "Pending"
        INPROCESS : "InProcess"
        DONE      : "Done"
        ROLLBACK  : "Rollback"
        FAILED    : "Failed"

    OPS_CODE_NAME =
        LAUNCH       : "Forge.Stack.Run"
        STOP         : "Forge.App.Stop"
        START        : "Forge.App.Start"
        UPDATE       : "Forge.App.Update"
        STATE_UPDATE : "Forge.AppState.Update"
        TERMINATE    : "Forge.App.Terminate"
        APP_SAVE     : "Forge.App.Save"
        APP_IMPORT   : "Forge.App.SaveImport"

    #private, recent items threshold
    DEMO_STACK_NAME_LIST = [ 'vpc-with-private-subnet-and-vpn', 'vpc-with-public-and-private-subnets-and-vpn', 'vpc-with-public-subnet-only', 'vpc-with-public-and-private-subnets' ]

    TA = ERROR: 'ERROR', WARNING: 'WARNING', NOTICE: 'NOTICE'

    LINUX   = ['centos', 'redhat',  'rhel', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensuse', 'suse', 'sles', 'amazon', 'amaz', 'linux-other']
    WINDOWS = ['windows', 'win']

    OS_TYPE_MAPPING =
        'linux-other' : 'linux'
        'redhat'      : 'rhel'
        'suse'        : 'sles'
        'windows'     : 'mswin'

    REGEXP =
        'stateEditorReference'        : /@\{([A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12})\.\w+\}/g
        'stateEditorOriginReference': /@\{(([\w-]+)\.(([\w-]+(\[\d+\])?)|state.[\w-]+))\}/g
        'stateEditorRefOnly'        : /^@\{(([\w-]+)\.(([\w-]+(\[\d+\])?)|state.[\w-]+))\}$/
        'uid'                        : /[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}/g

    # A map that used by the state editor.
    # It shows which attribute of components can be referenced.
    STATE_REF_DICT =
        _id : "property"
        AWS_VPC_CustomerGateway :
            __array   : false
            IpAddress : false
            Type      : false
            BgpAsn    : false
        AWS_EC2_Instance :
            __array          : false
            PublicIp         : true
            MacAddress       : true
            PrivateIpAddress : true
        AWS_AutoScaling_Group :
            __array           : true
            PublicIp          : true
            MacAddress        : true
            AvailabilityZones : true
            PrivateIpAddress  : true
        AWS_VPC_Subnet :
            __array                 : false
            AvailableIpAddressCount : false
            AvailabilityZone        : false
            CidrBlock               : false
        AWS_VPC_NetworkInterface :
            __array          : true
            PublicIp         : true
            MacAddress       : true
            PrivateIpAddress : true
        AWS_ELB :
            __array : false
            DNSName : false
            CanonicalHostedZoneName : false
            CanonicalHostedZoneNameID : false
            AvailabilityZones : true
        AWS_VPC_VPC :
            __array   : false
            CidrBlock : false
        AWS_EC2_InstanceGroup :
            __array          : false
            PublicIp         : true
            MacAddress       : true
            PrivateIpAddress : true
        AWS_RDS_DBInstance :
            Address          : true
            Port             : true

    MESOS_AMI_IDS = [
      {"region":"us-east-1","imageId":"ami-9ef278f6"}
      {"region":"us-west-1","imageId":"ami-353f2970"}
      {"region":"eu-west-1","imageId":"ami-1a92266d"}
      {"region":"us-west-2","imageId":"ami-fba3e8cb"}
      {"region":"eu-central-1","imageId":"ami-929caa8f"}
      {"region":"ap-southeast-2","imageId":"ami-5fe28d65"}
      {"region":"ap-northeast-1","imageId":"ami-9d7f479c"}
      {"region":"ap-southeast-1","imageId":"ami-a6a083f4"}
      {"region":"sa-east-1","imageId":"ami-c79e28da"}
    ]


    #public
    AWS_RESOURCE_KEY        : AWS_RESOURCE_KEY
    INSTANCE_STATES         : INSTANCE_STATES

    AWS_RESOURCE_SHORT_TYPE : AWS_RESOURCE_SHORT_TYPE
    REGION_KEYS             : REGION_KEYS
    REGION_SHORT_LABEL      : REGION_SHORT_LABEL
    REGION_LABEL            : REGION_LABEL
    RETURN_CODE             : RETURN_CODE
    LINUX                   : LINUX
    WINDOWS                 : WINDOWS
    #SERVICE_ERROR_MESSAGE  : SERVICE_ERROR_MESSAGE
    MESSAGE_E               : MESSAGE_E
    OPS_STATE               : OPS_STATE
    OPS_CODE_NAME           : OPS_CODE_NAME
    DEMO_STACK_NAME_LIST    : DEMO_STACK_NAME_LIST
    TA                      : TA
    OS_TYPE_MAPPING         : OS_TYPE_MAPPING
    REGEXP                  : REGEXP
    RESTYPE                 : RESTYPE
    STATE_REF_DICT          : STATE_REF_DICT
    RESNAME                 : wrap RESNAME
    HASTAG                  : wrap HASTAG
    WRAP                    : wrap

    DB_INSTANCECLASS        : DB_INSTANCECLASS
    DB_ENGINE               : DB_ENGINE
    DB_ENGINTYPE            : DB_ENGINTYPE
    DB_ENGINE_ARY           : DB_ENGINE_ARY
    DB_DEFAULTSETTING       : DB_DEFAULTSETTING

    MESOS_AMI_IDS           : MESOS_AMI_IDS