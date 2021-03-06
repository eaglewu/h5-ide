# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =
  PROP:

    LBL_REQUIRED:
      en: "Required"
      zh: "必填"

    DEFAULT:
      en: "Default"
      zh: "默认"

    LBL_DONE:
      en: "Done"
      zh: "完成"

    LBL_CANCEL:
      en: "Cancel"
      zh: "取消"

    LBL_LOADING:
      en: "Loading..."
      zh: "加载中..."

    LBL_VALIDATION:
      en: "Validation"
      zh: "验证"

    LBL_PROPERTY:
      en: "Property"
      zh: "属性"

    LBL_STATE:
      en: "States"
      zh: "States"

    LBL_OWNER:
      en: "Owner"
      zh: "所有者"

    LBL_ERROR:
      en: "Error"
      zh: "错误"

    LBL_WARNING:
      en: "Warning"
      zh: "警告"

    LBL_NOTICE:
      en: 'Notice'
      zh: "提示"

    LBL_STARTED:
      en: "Started"
      zh: "开始"

    INSTANCE_DETAIL:
      en: "Instance Details"
      zh: "实例详情"

    INSTANCE_HOSTNAME:
      en: "Hostname"
      zh: "主机名"

    INSTANCE_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    INSTANCE_LAUNCH_TIME:
      en: "Launch Time"
      zh: "创建时间"

    INSTANCE_STATE:
      en: "State"
      zh: "状态"

    INSTANCE_STATUS:
      en: "Status"
      zh: "状态"

    INSTANCE_PRIMARY_PUBLIC_IP:
      en: "Primary Public IP"
      zh: "主公网IP"

    INSTANCE_PUBLIC_IP:
      en: "Public IP"
      zh: "公网IP"

    INSTANCE_PUBLIC_DNS:
      en: "Public DNS"
      zh: "公网域名"

    INSTANCE_PRIMARY_PRIVATE_IP:
      en: "Primary Private IP"
      zh: "主内网IP"

    INSTANCE_PRIVATE_DNS:
      en: "Private DNS"
      zh: "内网域名"

    INSTANCE_NUMBER:
      en: "Number of Instance"
      zh: "实例数量"

    INSTANCE_REQUIRE:
      en: "Required"
      zh: "必须"

    INSTANCE_AMI:
      en: "AMI"
      zh: "AMI"

    INSTANCE_TYPE:
      en: "Instance Type"
      zh: "实例类型"

    INSTANCE_KEY_PAIR:
      en: "Key Pair"
      zh: "密钥对"

    INSTANCE_CLOUDWATCH_DETAILED_MONITORING:
      en: "CloudWatch Detailed Monitoring"
      zh: "CloudWatch 详细监控"

    INSTANCE_TENANCY:
      en: "Tenancy"
      zh: "硬件租赁"

    INSTANCE_TENANCY_DEFAULT:
      en: "Default"
      zh: "默认"

    INSTANCE_TENANCY_DELICATED:
      en: "Dedicated"
      zh: "专用"

    INSTANCE_ROOT_DEVICE_TYPE:
      en: "Block Device Type"
      zh: "根设备类型"

    INSTANCE_BLOCK_DEVICE:
      en: "Block Devices"
      zh: "块设备"

    INSTANCE_DEFAULT_KP:
      en: "$DefaultKeyPair"
      zh: "$DefaultKeyPair"

    KP_NAME:
      en: "Key Pair Name"
      zh: "密钥对名称"

    KP_CREATED_NEED_TO_DOWNLOAD:
      en: "Key pair <span></span> is created. You have to download the private key file (*.pem file) before you can continue. Store it in a secure and accessible location. You will not be able to download the file again after it's created."
      zh: "密钥对 <span></span> 创建完成, 您需要下载私钥(*.pem 文件)才能继续, 请将其保存于安全的位置, 创建完成之后您将无法再次下载。"

    KP_CONFIRM_DELETE_1:
      en: "Confirm to delete "
      zh: "确认删除"

    KP_CONFIRM_DELETE_2:
      en: "selected %s key pairs?"
      zh: "已选择的 %s 个密钥对吗?"

    KP_CONFIRM_DELETE_3:
      en: "key pair %s ?"
      zh: "密钥对 %s 吗?"

    KP_SELECT_A_FILE:
      en: "Select a file"
      zh: "选择一个文件"

    KP_OR_PASTE_KEY_CONTENT:
      en: "or paste the key content here."
      zh: "或者将密钥对的内容粘贴在这"

    KP_OR_PASTE_TO_UPDATE:
      en: "or paste the key content again to update."
      zh: "或者再次粘贴密钥对的内容以更新"

    AZ_AND_SUBNET:
      en: "AZ & subnet"
      zh: "可用区和子网"

    EIP_DOMAIN:
      en: "Elastic IP Domain"
      zh: "弹性IP 域"

    EIP_CONFIRM_RELEASE_1:
      en: "Confirm to release "
      zh: "确定释放"

    EIP_CONFIRM_RELEASE_2:
      en: "selected %s Elastic IPs?"
      zh: "已选择的 %s 个弹性IP 吗？"

    EIP_CONFIRM_RELEASE_3:
      en: "Elastic IP %s?"
      zh: "弹性 IP (%s) 吗？"

    EIP_CONFIRM_RELEASE_BTN:
      en: "Release"
      zh: "释放"

    EIP_CONFIRM_TO_CREATE:
      en: "Are you sure you want to allocate a new IP address?"
      zh: "确定要分配新的弹性 IP 吗？"

    EIP_DROPDOWN_MANAGE:
      en: "Manage Elastic IPs"
      zh: "管理弹性 IP"

    EIP_DROPDOWN_FILTER:
      en: "Filter Elastic IPs"
      zh: "过滤弹性 IP"

    EIP_RESOURCE_NAME:
      en: "Elastic IPs"
      zh: "弹性 IP"

    SELECT_EIP_SELECTION:
      en: "Select Elastic IP"
      zh: "选择弹性 IP"

    EIP_NEED_SELECT:
      en: "You need specify a Elastic IP to assign."
      zh: "您需要指定一个弹性 IP 用来分配。"

    EIP_SELECT_IP_LABEL:
      en: "Select Elastic IP"
      zh: "选择弹性 IP"

    ASSIGN_NEW_ELASTIC_IP:
      en: "Assign new Elastic IP"
      zh: "分配新的弹性 IP"

    EIP_SELECTOR_CONFIRM_LABEL:
      en: "Assign"
      zh: "分配"

    EIP_SELECTOR_CONFIRM_TITLE:
      en: "Please select a unallocated EIP to assign"
      zh: "请选择要分配的弹性 IP"

    ASSIGN_NEW_ELASTIC_IP_DESC:
      en: "A new Elastic IP will assign automatically."
      zh: "将自动分配一个新的弹性 IP"

    ASSIGN_OLD_ELASTIC_IP:
      en: "Current Elastic IP"
      zh: "使用当前的弹性 IP"

    ASSIGN_OLD_ELASTIC_IP_DESC:
      en: "Continue use current EIP instead of assign a new EIP."
      zh: "不分配新的EIP， 继续使用原来的 EIP."

    OG_NO_OPTION_GROUP:
      en: "No Option Group"
      zh: "无选项组"

    OG_CREATE_OPTION_GROUP:
      en: "Create Option Group"
      zh: "创建选项组"

    OG_PORT:
      en: "Port"
      zh: "端口"

    KP_SECURITY_GROUP:
      en: "Security Group"
      zh: "安全组"

    KP_OPTION_SETTING:
      en: "Option Setting"
      zh: "选项设置"

    INSTANCE_NO_KP:
      en: "No Key Pair"
      zh: "无密钥对"

    INSTANCE_NEW_KP:
      en: "Create New Key Pair"
      zh: "新建密钥对"

    INSTANCE_FILTER_KP:
      en: "Filter by key pair name"
      zh: "过滤密钥对名"

    INSTANCE_MANAGE_KP:
      en: "Manage Region Key Pairs ..."
      zh: "管理区域密钥对"

    INSTANCE_FILTER_SNS:
      en: "Filter by SNS Topic name"
      zh: "过滤 SNS 主题名称"

    INSTANCE_MANAGE_SNS:
      en: "Manage SNS Topic ..."
      zh: "管理 SNS 主题"

    INSTANCE_FILTER_SSL_CERT:
      en: "Filter by SSL Certificate name"
      zh: "过滤 SSL 认证名称"

    INSTANCE_MANAGE_SSL_CERT:
      en: "Manage SSL Certificate..."
      zh: "管理 SSL 认证"

    INSTANCE_TIP_DEFAULT_KP:
      en: 'If you have used $DefaultKeyPair for any instance/launch configuration, you will be required to specify an existing key pair for $DefaultKeyPair. Or you can choose "No Key Pair" as $DefaultKeyPair.'
      zh: "如果您在任何实例或者启动配置里使用了 $DefaultKeyPair, 您将需要为 $DefaultKeyPair 指定一个存在的密钥对, 或者您也可以选择'无密钥对'"

    INSTANCE_TIP_NO_KP:
      en: "If you select no key pair, you will not be able to connect to the instance unless you already know the password built into this AMI."
      zh: "如果您选择了 “无密钥对”, 您将无法连接到实例, 除非您已经知道烧录的 AMI 的密码。"

    INSTANCE_CW_ENABLED:
      en: "Enable CloudWatch Detailed Monitoring"
      zh: "启用 CloudWatch 详细监控"

    INSTANCE_ADVANCED_DETAIL:
      en: "Advanced Details"
      zh: "高级设置"

    INSTANCE_USER_DATA:
      en: "User Data"
      zh: "用户数据"

    RESOURCE_TAGS:
      en: "Tags"
      zh: "资源标签"

    RESOURCE_NO_TAGS:
      en: "This resource has no tags"
      zh: "该资源没有标签"

    RESOURCE_EDIT_TAG:
      en: "Edit Tags..."
      zh: "编辑标签..."

    INSTANCE_USER_DATA_DETAIL:
      en: "View User Data Detail"
      zh: "查看详细用户数据"

    INSTANCE_USER_DATA_DISABLE:
      en: "Can't edit user data when instance state exist"
      zh: "Instance State 存在的情况下无法编辑 user data"

    INSTANCE_CW_WARN:
      en: "Data is available in 1-minute periods at an additional cost. For information about pricing, go to the "
      zh: "1分钟内即可用的数据需要额外花费．要获取价格信息，请访问 "

    AGENT_USER_DATA_URL:
      en: "https://github.com/MadeiraCloud/OpsAgent/blob/develop/scripts/userdata.sh"
      zh: "https://github.com/MadeiraCloud/OpsAgent/blob/develop/scripts/userdata.sh"

    INSTANCE_ENI_DETAIL:
      en: "Network Interface Details"
      zh: "网卡详情"

    INSTANCE_ENI_DESC:
      en: "Description"
      zh: "描述"

    INSTANCE_ENI_SOURCE_DEST_CHECK:
      en: "Enable Source/Destination Checking"
      zh: "启用源/目标检查"

    INSTANCE_ENI_SOURCE_DEST_CHECK_DISP:
      en: "Source/Destination Checking"
      zh: "源/目标检查"

    INSTANCE_ENI_AUTO_PUBLIC_IP:
      en: "Automatically assign Public IP"
      zh: "自动分配公网IP"

    INSTANCE_ENI_IP_ADDRESS:
      en: "IP Address"
      zh: "IP地址"

    INSTANCE_ENI_ADD_IP:
      en: "Add IP"
      zh: "添加IP"

    INSTANCE_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    INSTANCE_IP_MSG_1:
      en: "Specify an IP address or leave it as .x to automatically assign an IP."
      zh: "请提供一个IP或者保留为.x来自动分配IP。"

    INSTANCE_IP_MSG_2:
      en: "Automatically assigned IP."
      zh: "自动分配IP"

    INSTANCE_IP_MSG_3:
      en: "Associate with Elastic IP"
      zh: "关联弹性 IP"

    INSTANCE_IP_MSG_4:
      en: "Detach Elastic IP"
      zh: "取消关联弹性 IP"

    INSTANCE_AMI_ID:
      en: "AMI ID"
      zh: "AMI ID"

    INSTANCE_AMI_NAME:
      en: "Name"
      zh: "AMI名称"

    INSTANCE_AMI_DESC:
      en: "Description"
      zh: "描述"

    INSTANCE_AMI_ARCHITECH:
      en: "Architecture"
      zh: "架构"

    INSTANCE_AMI_VIRTUALIZATION:
      en: "Virtualization"
      zh: "虚拟化"

    INSTANCE_AMI_KERNEL_ID:
      en: "Kernel ID"
      zh: "内核ID"

    INSTANCE_AMI_OS_TYPE:
      en: "Type"
      zh: "操作系统类型"

    INSTANCE_AMI_SUPPORT_INSTANCE_TYPE:
      en: "Support Instance"
      zh: "支持实例类型"

    INSTANCE_KEY_MONITORING:
      en: "Monitoring"
      zh: "监控"

    INSTANCE_KEY_ZONE:
      en: "Zone"
      zh: "地区"

    INSTANCE_AMI_LAUNCH_INDEX:
      en: "AMI Launch Index"
      zh: "AMI启动序号"

    INSTANCE_AMI_NETWORK_INTERFACE:
      en: "Network Interface"
      zh: "网络接口"

    INSTANCE_TIP_GET_SYSTEM_LOG:
      en: "Get System Log"
      zh: "获取系统日志"

    DB_INSTANCE_TIP_GET_LOG:
      en: "Get Logs & Events"
      zh: "获取日志和事件"

    INSTANCE_TIP_IF_THE_QUANTITY_IS_MORE_THAN_1:
      en: "If the quantity is more than 1, host name will be the string you provide plus number index."
      zh: "如果数量大于1, 主机名将为您提供的字符加索引数字"

    INSTANCE_TIP_YOU_CANNOT_SPECIFY_INSTANCE_NUMBER:
      en: "You cannot specify instance number, since the instance is connected to a route table."
      zh: "您不能指定实例数量, 因为实例已经连接到路由表中"

    INSTANCE_TIP_PUBLIC_IP_CANNOT_BE_ASSOCIATED:
      en: "Public IP cannot be associated if instance is launching with more than one network interface."
      zh: "当实例连接到的网络的数量多于一个时将无法指定公共 IP 地址"

    INSTANCE_GET_WINDOWS_PASSWORD:
      en: "Get Windows Password"
      zh: "获取 Windows 密码"

    AMI_STACK_NOT_AVAILABLE:
      en: "<p>This AMI is not available. It may have been deleted by its owner or not shared with your AWS account. </p><p>Please change to another AMI.</p>"
      zh: "<p>此 AMI 不可用, 可能已经被所有者删除或者不再与您的 AWS 账号共享。 </p><p>请选择其他的 AMI。</p>"

    AMI_APP_NOT_AVAILABLE:
      en: "This AMI's information is unavailable."
      zh: "此 AMI 的信息不可用。"

    STACK_AMAZON_ARN:
      en: "Amazon ARN"
      zh: "Amazon ARN"

    STACK_EXAMPLE_EMAIL:
      en: "example@acme.com"
      zh: "example@acme.com"

    STACK_E_G_1_206_555_6423:
      en: "e.g. 1-206-555-6423"
      zh: "例: 1-206-555-6423"

    STACK_HTTP_WWW_EXAMPLE_COM:
      en: "http://www.example.com"
      zh: "http://www.example.com"

    STACK_HTTPS_WWW_EXAMPLE_COM:
      en: "https://www.example.com"
      zh: "https://www.example.com"

    STACK_HTTPS:
      en: "https"
      zh: "https"

    STACK_HTTP:
      en: "http"
      zh: "http"

    STACK_USPHONE:
      en: "usPhone"
      zh: "usPhone"

    STACK_EMAIL:
      en: "email"
      zh: "email"

    STACK_ARN:
      en: "arn"
      zh: "arn"

    STACK_SQS:
      en: "sqs"
      zh: "sqs"

    STACK_PENDING_CONFIRM:
      en: "pendingConfirm"
      zh: "pendingConfirm"

    STACK_LBL_NAME:
      en: "Stack Name"
      zh: "Stack 名称"

    APP_LBL_NAME:
      en: "App Name"
      zh: "App 名称"

    STACK_LBL_DESCRIPTION:
      en: "Stack Description"
      zh: "Stack 描述"

    STACK_LBL_REGION:
      en: "Region"
      zh: "地区"

    STACK_LBL_TYPE:
      en: "Type"
      zh: "类型"

    STACK_LBL_ID:
      en: "Stack ID"
      zh: "Stack ID"

    APP_LBL_ID:
      en: "App ID"
      zh: "App ID"

    APP_LBL_INSTANCE_STATE:
      en: "Instance State"
      zh: "Instance State"

    APP_LBL_RESDIFF:
      en: "Monitor and report external resource change of this app"
      zh: "监控并报告此 App 的外部资源变化"

    APP_LBL_RESDIFF_VIEW:
      en: "Monitor and Report External Change"
      zh: "监控并报告外部变化"

    APP_TIP_RESDIFF:
      en: "If resource has been changed outside VisualOps, an email notification will be sent to you."
      zh: "如果资源在 VisualOps 外发生变化, 将会给您发送一封通知邮件"

    APP_DIFF_CHANGE_CONFIRM:
      en: "OK, got it"
      zh: "确定"

    STACK_LBL_USAGE:
      en: "Usage"
      zh: "用途"

    STACK_TIT_SG:
      en: "Security Groups"
      zh: "安全组"

    STACK_TIT_ACL:
      en: "Network ACL"
      zh: "网络 ACL"

    STACK_TIT_SNS:
      en: "SNS Topic Subscription"
      zh: "SNS主题订阅"

    STACK_BTN_ADD_SUB:
      en: "Add Subscription"
      zh: "添加订阅"

    STACK_TIT_COST_ESTIMATION:
      en: "Cost Estimation"
      zh: "成本估算"

    STACK_LBL_COST_CYCLE:
      en: "month"
      zh: "月"

    STACK_COST_COL_RESOURCE:
      en: "Resource"
      zh: "资源"

    STACK_COST_COL_SIZE_TYPE:
      en: "Size/Type"
      zh: "大小/类型"

    STACK_COST_COL_FEE:
      en: "Fee($)"
      zh: "价格($)"

    STACK_LBL_AWS_EC2_PRICING:
      en: "Amazon EC2 Pricing"
      zh: "Amazon EC2 定价"

    STACK_ACL_LBL_RULE:
      en: "rules"
      zh: "条规则"

    STACK_ACL_LBL_ASSOC:
      en: "associations"
      zh: "个关联"

    STACK_ACL_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    STACK_ACL_TIP_DETAIL:
      en: "Go to Network ACL Details"
      zh: "查看网络 ACL详情"

    STACK_BTN_CREATE_NEW_ACL:
      en: "Create new Network ACL..."
      zh: "创建新的网络 ACL..."

    APP_SNS_NONE:
      en: "This app has no SNS Subscription"
      zh: "本App不含SNS订阅"

    AZ_LBL_SWITCH:
      en: "Quick Switch Availability Zone"
      zh: "切换可用区域"

    VPC_TIT_DETAIL:
      en: "VPC Details"
      zh: "VPC 详情"

    VPC_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    VPC_DETAIL_LBL_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    VPC_DETAIL_LBL_TENANCY:
      en: "Tenancy"
      zh: "硬件租赁"

    VPC_DETAIL_TENANCY_LBL_DEFAULT:
      en: "Default"
      zh: "默认"

    VPC_DETAIL_TENANCY_LBL_DEDICATED:
      en: "Dedicated"
      zh: "专用"

    VPC_DETAIL_LBL_ENABLE_DNS_RESOLUTION:
      en: "Enable DNS resolution"
      zh: "允许 DNS 解析"

    VPC_DETAIL_LBL_ENABLE_DNS_HOSTNAME_SUPPORT:
      en: "Enable DNS hostname support"
      zh: "允许 DNS 主机名解析"

    VPC_TIT_DHCP_OPTION:
      en: "DHCP Options"
      zh: "DHCP 选项"

    VPC_DHCP_LBL_NONE:
      en: "Default"
      zh: "无"

    VPC_DHCP_LBL_DEFAULT:
      en: "Auto-assigned Set"
      zh: "缺省"

    VPC_DHCP_LBL_SPECIFIED:
      en: "Specified DHCP Options Set"
      zh: "指定的 DHCP 选项设置"

    VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME:
      en: "Domain Name"
      zh: "域名"

    VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME_SERVER:
      en: "Domain Name Server"
      zh: "域名服务器"

    VPC_DHCP_SPECIFIED_LBL_AMZN_PROVIDED_DNS:
      en: "AmazonProvidedDNS"
      zh: "亚马逊提供的域名服务器"

    VPC_DHCP_SPECIFIED_LBL_NTP_SERVER:
      en: "NTP Server"
      zh: "时间服务器"

    VPC_DHCP_SPECIFIED_LBL_NETBIOS_NAME_SERVER:
      en: "NetBIOS Name Server"
      zh: "NetBIOS名字服务器"

    VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE:
      en: "NetBIOS Node Type"
      zh: "NetBIOS 节点类型"

    VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED:
      en: "Not specified"
      zh: "未指定"

    VPC_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    VPC_APP_STATE:
      en: "State"
      zh: "状态"

    VPC_APP_CIDR:
      en: "CIDR"
      zh: "CIDR"

    VPC_APP_MAIN_RT:
      en: "Main Route Table"
      zh: "主路由表"

    VPC_APP_DEFAULT_ACL:
      en: "Default Network ACL"
      zh: "缺省网络 ACL"

    VPC_DHCP_OPTION_SET_ID:
      en: "DHCP Options Set ID"
      zh: "DHCP 选项标识"

    VPC_MANAGE_DHCP:
      en: "Manage DHCP Options Set"
      zh: "管理 DHCP 选项组"

    VPC_MANAGE_RDS_PG:
      en: "Manage Parameter Group"
      zh: "管理参数组"

    VPC_FILTER_RDS_PG:
      en: "Filter by Parameter Group Name"
      zh: "过滤参数组名称"

    VPC_FILTER_DHCP:
      en: "Filter by DHCP Options Set ID"
      zh: "过滤 DHCP 选项 ID"

    VPC_TIP_AUTO_DHCP:
      en: "A DHCP Options set will be automatically assigned for the VPC by AWS."
      zh: "AWS 将会给 VPC 自动分配一个 DHCP 选项组"

    VPC_TIP_DEFAULT_DHCP:
      en: "The VPC will use no DHCP options."
      zh: "此 VPC 将不使用 DHCP 选项"

    VPC_AUTO_DHCP:
      en: "Auto-assigned Set"
      zh: "自动分配"

    VPC_DEFAULT_DHCP:
      en: "Default"
      zh: "Default"

    SUBNET_TIP_CIDR_BLOCK:
      en: "e.g. 10.0.0.0/24. The range of IP addresses in the subnet must be a subset of the IP address in the VPC. Block sizes must be between a /16 netmask and /28 netmask. The size of the subnet can equal the size of the VPC."
      zh: "例: 10.0.0.0/24. 子网里的 IP 地址的区间必须在所在 VPC 的地址区间里。区块大小必须在 /16 子网掩码 和 /28 子网掩码之间。子网的大小可以等于 VPC 的大小。"

    SUBNET_TIT_DETAIL:
      en: "Subnet Details"
      zh: "子网详情"

    SUBNET_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    SUBNET_DETAIL_LBL_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    SUBNET_TIT_ASSOC_ACL:
      en: "Associated Network ACL"
      zh: "相关网络 ACL"

    SUBNET_BTN_CREATE_NEW_ACL:
      en: "Create new Network ACL..."
      zh: "创建新的网络 ACL..."

    SUBNET_ACL_LBL_RULE:
      en: "rules"
      zh: "条规则"

    SUBNET_ACL_LBL_ASSOC:
      en: "associations"
      zh: "个关联"

    SUBNET_ACL_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    SUBNET_ACL_TIP_DETAIL:
      en: "Go to Network ACL Details"
      zh: "查看网络 ACL 详情"

    SUBNET_APP_ID:
      en: "Subnet ID"
      zh: "子网 ID"

    SUBNET_APP_STATE:
      en: "State"
      zh: "状态"

    SUBNET_APP_CIDR:
      en: "CIDR"
      zh: "CIDR"

    SUBNET_APP_AVAILABLE_IP:
      en: "Available IPs"
      zh: "可用 IP"

    SUBNET_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    SUBNET_APP_RT_ID:
      en: "Route Table ID"
      zh: "路由表 ID"

    VPC_TIP_EG_10_0_0_0_16:
      en: "e.g. 10.0.0.0/16"
      zh: "例:  10.0.0.0/16"

    VPC_TIP_ENTER_THE_DOMAIN_NAME:
      en: "Enter the domain name that should be used for your hosts"
      zh: "输入主机将要使用的域名"

    VPC_TIP_ENTER_UP_TO_4_DNS:
      en: "Enter up to 4 DNS server IP addresses"
      zh: "输入最多4个 DNS 服务器地址"

    VPC_TIP_ENTER_UP_TO_4_NTP:
      en: "Enter up to 4 NTP server IP addresses"
      zh: "输入最多4个 NTP 服务器地址"

    VPC_TIP_ENTER_UP_TO_4_NETBIOS:
      en: "Enter up to 4 NetBIOS server IP addresses"
      zh: "输入最多4个 NetBIOS 服务器地址"

    VPC_TIP_EG_172_16_16_16:
      en: "e.g. 172.16.16.16"
      zh: "例:  172.16.16.16"

    VPC_TIP_SELECT_NETBIOS_NODE:
      en: "Select NetBIOS Node Type. We recommend 2. (Broadcast and multicast are currently not supported by AWS.)"
      zh: "选择 NetBIOS 节点类型, 我们推荐选项2。(AWS 尚未支持广播和多播)"

    SG_TIT_DETAIL:
      en: "Security Group Details"
      zh: "安全组详情"

    SG_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    SG_TIT_RULE:
      en: "Rule"
      zh: "规则"

    SG_RULE_SORT_BY:
      en: "Sort by"
      zh: "排序"

    SG_RULE_SORT_BY_DIRECTION:
      en: "Direction"
      zh: "按方向"

    SG_RULE_SORT_BY_SRC_DEST:
      en: "Source/Destination"
      zh: "按源/目标"

    SG_RULE_SORT_BY_PROTOCOL:
      en: "Protocol"
      zh: "按协议"

    SG_TIT_MEMBER:
      en: "Member"
      zh: "成员"

    SG_TIP_CREATE_RULE:
      en: "Create rule referencing IP Range"
      zh: "创建基于IP范围的规则"

    SG_TIP_REMOVE_RULE:
      en: "Remove rule"
      zh: "删除规则"

    SG_TIP_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    SG_TIP_SRC:
      en: "Source"
      zh: "源"

    SG_TIP_DEST:
      en: "Destination"
      zh: "目的"

    SG_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    SG_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    SG_TIP_PORT_CODE:
      en: "Port or Code"
      zh: "端口或代码"

    SG_APP_SG_ID:
      en: "Security Group ID"
      zh: "安全组标识"

    SG_APP_SG_NAME:
      en: "Security Group Name"
      zh: "安全组名字"

    SG_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    SGLIST_LBL_RULE:
      en: "rules"
      zh: "条规则"

    SGLIST_LBL_MEMBER:
      en: "members"
      zh: "个成员"

    SGLIST_LNK_DELETE:
      en: "Delete"
      zh: "删除"

    SGLIST_TIP_VIEW_DETAIL:
      en: "View details"
      zh: "查看详情"

    SGLIST_BTN_CREATE_NEW_SG:
      en: "Create new Security Group..."
      zh: "创建新安全组..."

    SGLIST_TAB_GROUP:
      en: "Group"
      zh: "组"

    SGLIST_TAB_RULE:
      en: "Rule"
      zh: "规则"

    SGRULE_DESCRIPTION:
      en: "The selected connection reflects following security group rule(s):"
      zh: "当前选中的连线反映了以下安全组的规则:"

    SGRULE_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    SGRULE_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    SGRULE_BTN_EDIT_RULE:
      en: "Edit Related Rule"
      zh: "编辑相关规则"

    ACL_LBL_NAME:
      en: "Name"
      zh: "名称"

    ACL_TIT_RULE:
      en: "Rule"
      zh: "规则"

    ACL_BTN_CREATE_NEW_RULE:
      en: "Create new Network ACL Rule"
      zh: "创建新的网络 ACL"

    ACL_RULE_SORT_BY:
      en: "Sort by"
      zh: "排序"

    ACL_RULE_SORT_BY_NUMBER:
      en: "Rule Number"
      zh: "按规则编号"

    ACL_RULE_SORT_BY_ACTION:
      en: "Action"
      zh: "动作"

    ACL_RULE_SORT_BY_DIRECTION:
      en: "Direction"
      zh: "方向"

    ACL_RULE_SORT_BY_SRC_DEST:
      en: "Source/Destination"
      zh: "源/目标"

    ACL_TIP_ACTION_ALLOW:
      en: "allow"
      zh: "允许"

    ACL_TIP_ACTION_DENY:
      en: "deny"
      zh: "拒绝"

    ACL_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    ACL_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    ACL_TIP_RULE_NUMBER:
      en: "Rule Number"
      zh: "规则编号"

    ACL_TIP_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    ACL_TIP_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    ACL_TIT_ASSOC:
      en: "Associations"
      zh: "关联的子网"

    ACL_TIP_REMOVE_RULE:
      en: "Remove rule"
      zh: "删除规则"

    ACL_APP_ID:
      en: "Network ACL ID"
      zh: "网络 ACL标识"

    ACL_APP_IS_DEFAULT:
      en: "Default"
      zh: "是否缺省"

    ACL_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    VGW_TXT_DESCRIPTION:
      en: "The Virtual Private Gateway is the router on the Amazon side of the VPN tunnel."
      zh: "虚拟私有网关是亚马逊一侧的VPN隧道的路由器"

    VPN_LBL_IP_PREFIX:
      en: "Network IP Prefixes"
      zh: "网络 IP 地址前缀"

    VPN_TIP_EG_192_168_0_0_16:
      en: "e.g., 192.168.0.0/16"
      zh: "例: 192.168.0.0/16"

    VPN_SUMMARY:
      en: "VPN Summary"
      zh: "VPN 概要"

    IGW_TXT_DESCRIPTION:
      en: "The Internet gateway is the router on the AWS network that connects your VPC to the Internet."
      zh: "互联网网关是将位于AWS网络中的VPC网络连接到互联网的路由器"

    CGW_LBL_NAME:
      en: "Name"
      zh: "名称"

    CGW_LBL_IPADDR:
      en: "IP Address"
      zh: "IP地址"

    CGW_LBL_ROUTING:
      en: "Routing"
      zh: "路由"

    CGW_LBL_STATIC:
      en: "Static"
      zh: "静态"

    CGW_LBL_DYNAMIC:
      en: "Dynamic"
      zh: "动态"

    CGW_LBL_BGP_ASN:
      en: "BGP ASN"
      zh: "BGP 自治域号"

    CGW_APP_TIT_CGW:
      en: "Customer Gateway"
      zh: "客户网关"

    CGW_APP_CGW_LBL_ID:
      en: "ID"
      zh: "标识"

    CGW_APP_CGW_LBL_STATE:
      en: "State"
      zh: "状态"

    CGW_APP_CGW_LBL_TYPE:
      en: "Type"
      zh: "类型"

    CGW_APP_TIT_VPN:
      en: "VPN Connection"
      zh: "VPN连接"

    CGW_APP_VPN_LBL_ID:
      en: "ID"
      zh: "标识"

    CGW_APP_VPN_LBL_STATE:
      en: "State"
      zh: "状态"

    CGW_APP_VPN_LBL_TYPE:
      en: "Type"
      zh: "类型"

    CGW_APP_VPN_LBL_TUNNEL:
      en: "VPN Tunnels"
      zh: "VPN隧道"

    CGW_APP_VPN_COL_TUNNEL:
      en: "Tunnel"
      zh: "隧道"

    CGW_APP_VPN_COL_IP:
      en: "IP Address"
      zh: "IP地址"

    CGW_APP_VPN_LBL_STATUS_RT:
      en: "Static Routes"
      zh: "静态路由"

    CGW_APP_VPN_COL_IP_PREFIX:
      en: "IP Prefixes"
      zh: "网络号"

    CGW_APP_VPN_COL_SOURCE:
      en: "Source"
      zh: "源"

    CGW_APP_TIT_DOWNLOAD_CONF:
      en: "Download Configuration"
      zh: "下载配置"

    CGW_APP_DOWN_LBL_VENDOR:
      en: "Vendor"
      zh: "厂商"

    CGW_APP_DOWN_LBL_PLATFORM:
      en: "Platform"
      zh: "平台"

    CGW_APP_DOWN_LBL_SOFTWARE:
      en: "Software"
      zh: "软件"

    CGW_APP_DOWN_LBL_GENERIC:
      en: "Generic"
      zh: "通用"

    CGW_APP_DOWN_LBL_VENDOR_AGNOSTIC:
      en: "Vendor Agnostic"
      zh: "厂商无关"

    CGW_APP_DOWN_BTN_DOWNLOAD:
      en: "Download"
      zh: "下载"

    CGW_TIP_THIS_ADDRESS_MUST_BE_STATIC:
      en: "This address must be static and not behind a NAT. e.g. 12.1.2.3"
      zh: "此地址必须为静态并且不能在 NAT 网络中。 如: 12.1.2.3"

    CGW_TIP_1TO65534:
      en: "1 - 65534"
      zh: "1 - 65534"

    MSG_ERR_RESOURCE_NOT_EXIST:
      en: "Sorry, the selected resource not exist."
      zh: "抱歉，选定的资源不存在"

    MSG_ERR_DOWNLOAD_KP_FAILED:
      en: "Sorry, there was a problem downloading this key pair."
      zh: "抱歉，下载密钥对时出现了问题"

    MSG_WARN_NO_STACK_NAME:
      en: "Stack name empty or missing."
      zh: "Stack名称不能为空"

    MSG_WARN_REPEATED_STACK_NAME:
      en: "This stack name is already in use."
      zh: "这个Stack名称已被占用"

    MSG_WARN_ENI_IP_EXTEND:
      en: "%s Instance's Network Interface can't exceed %s Private IP Addresses."
      zh: "%s 实例的网络接口不能超过 %s 私有IP地址"

    MSG_WARN_NO_APP_NAME:
      en: "App name empty or missing."
      zh: "App名称不能为空"

    MSG_WARN_REPEATED_APP_NAME:
      en: "This app name is already in use."
      zh: "这个App名称已被占用"

    MSG_WARN_INVALID_APP_NAME:
      en: "App name is invalid."
      zh: "无效的App名称"

    WARN_EXCEED_ENI_LIMIT:
      en: "Instance type %s supports a maximum of %s network interfaces (including the primary). Please detach additional network interfaces before changing instance type."
      zh: "实例类型：%s 支持最多 %s 个网络接口（包括主要的）， 请在改变实例类型之前删除超出数量限制的网络接口"

    TEXT_DEFAULT_SG_DESC:
      en: "Default Security Group"
      zh: "Default Security Group"

    TEXT_CUSTOM_SG_DESC:
      en: "Custom Security Group"
      zh: "Custom Security Group"

    MSG_WARN_WHITE_SPACE:
      en: "Stack name contains white space"
      zh: "Stack名称不能包含空格"

    MSG_SG_CREATE:
      en: "1 rule has been created in %s to allow %s %s %s."
      zh: "1条规则被创建到 %s 来允许 %s %s %s"

    MSG_SG_CREATE_MULTI:
      en: "%d rules have been created in %s and %s to allow %s %s %s."
      zh: "%d条规则被创建到 %s 并且 %s 来允许 %s %s %s"

    MSG_SG_CREATE_SELF:
      en: "%d rules have been created in %s to allow %s send and receive traffic within itself."
      zh: "%d条规则被创建到 %s 来允许 %s 它内部的收发通信"

    SNAPSHOT_FILTER_REGION:
      en: "Filter by region name"
      zh: "按地区名过滤"

    SNAPSHOT_FILTER_VOLUME:
      en: "Filter by Volume ID"
      zh: "按磁盘ID过滤"

    VOLUME_DEVICE_NAME:
      en: "Device Name"
      zh: "挂载设备名"

    VOLUME_SIZE:
      en: "Volume Size"
      zh: "磁盘大小"

    VOLUME_ID:
      en: "Volume ID"
      zh: "磁盘ID"

    VOLUME_STATE:
      en: "State"
      zh: "状态"

    VOLUME_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    VOLUME_SNAPSHOT_ID:
      en: "Snapshot ID"
      zh: "快照ID"

    VOLUME_SNAPSHOT_SELECT:
      en: "Select volume from which to create snapshot"
      zh: "选择要创建快照的磁盘"

    VOLUME_SNAPSHOT_SELECT_REGION:
      en: "Select Destination Region"
      zh: "选择目标地区"

    VOLUME_SNAPSHOT:
      en: "Snapshot"
      zh: "快照"

    VOLUME_ATTACHMENT_STATE:
      en: "Attachment Status"
      zh: "挂载状态"

    VOLUME_ATTACHMENT_SET:
      en: "AttachmentSet"
      zh: "挂载数据集"

    VOLUME_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    VOLUME_ATTACHMENT_TIME:
      en: "Attach Time"
      zh: "挂载时间"

    VOLUME_TYPE:
      en: "Volume Type"
      zh: "磁盘类型"

    VOLUME_ENCRYPTED:
      en: "Encrypted"
      zh: "加密"

    VOLUME_ENCRYPTED_STATE:
      en: "Encrypted"
      zh: "加密的"

    VOLUME_NOT_ENCRYPTED_STATE:
      en: "Not Encrypted"
      zh: "不加密的"

    VOLUME_TYPE_STANDARD:
      en: "Magnetic"
      zh: "传统磁盘"

    VOLUME_TYPE_GP2:
      en: "General Purpose (SSD)"
      zh: "通用（SSD）"

    VOLUME_TYPE_IO1:
      en: "Provisioned IOPS (SSD)"
      zh: "预配置IOPS"

    VOLUME_MSG_WARN:
      en: "Volume size must be at least 10 GB to use Provisioned IOPS volume type."
      zh: "要使用预配置IOPS,磁盘必须最少10GB"

    VOLUME_ENCRYPTED_LABEL:
      en: "Encrypt this volume"
      zh: "加密该磁盘"

    ENI_LBL_ATTACH_WARN:
      en: "Attach the Network Interface to an instance within the same availability zone."
      zh: "在同一个可用区域里面附加网络接口"

    ENI_LBL_DETAIL:
      en: "Network Interface Details"
      zh: "网卡详情"

    ENI_SOURCE_DEST_CHECK:
      en: "Enable Source/Destination Checking"
      zh: "打开源/目标检查"

    ENI_AUTO_PUBLIC_IP:
      en: "Automatically assign Public IP"
      zh: "自动分配公网 IP"

    ENI_IP_ADDRESS:
      en: "IP Address"
      zh: "IP 地址"

    ENI_ADD_IP:
      en: "Add IP"
      zh: "添加 IP"

    ENI_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    ENI_DEVICE_NAME:
      en: "Device Name"
      zh: "设备名称"

    ENI_STATE:
      en: "State"
      zh: "状态"

    ENI_ID:
      en: "Network Interface ID"
      zh: "网卡ID"

    ENI_SHOW_DETAIL:
      en: "More"
      zh: "更多"

    ENI_HIDE_DETAIL:
      en: "Hide"
      zh: "隐藏"

    ENI_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    ENI_SUBNET_ID:
      en: "Subnet ID"
      zh: "子网ID"

    ENI_ATTACHMENT_ID:
      en: "Attachment ID"
      zh: "关联ID"

    ENI_Attachment_OWNER:
      en: "Owner"
      zh: "关联拥有者"

    ENI_Attachment_STATE:
      en: "State"
      zh: "关联状态"

    ENI_MAC_ADDRESS:
      en: "MAC Address"
      zh: "MAC地址"

    ENI_IP_OWNER:
      en: "IP Owner"
      zh: "IP拥有者"

    ENI_TIP_ADD_IP_ADDRESS:
      en: "Add IP Address"
      zh: "添加 IP 地址"

    ENI_PRIMARY:
      en: "Primary"
      zh: "主要"

    ELB_DETAILS:
      en: "Load Balancer Details"
      zh: "负载均衡器详情"

    ELB_NAME:
      en: "Name"
      zh: "名称"

    ELB_REQUIRED:
      en: "Required"
      zh: "必须"

    ELB_SCHEME:
      en: "Scheme"
      zh: "模式"

    ELB_LISTENER_DETAIL:
      en: "Listener Configuration"
      zh: "监听设置"

    ELB_BTN_ADD_LISTENER:
      en: "+ Add Listener"
      zh: "添加侦听器"

    ELB_BTN_ADD_SERVER_CERTIFICATE:
      en: "Add SSL Certificate"
      zh: "添加 SSL 证书"

    ELB_SERVER_CERTIFICATE:
      en: "SSL Certificate"
      zh: "SSL 认证"

    ELB_LBL_LISTENER_NAME:
      en: "Name"
      zh: "名称"

    ELB_LBL_LISTENER_DESCRIPTIONS:
      en: "Listener Descriptions"
      zh: "侦听器描述"

    ELB_LBL_LISTENER_CERT_NAME:
      en: "Certificate Name"
      zh: "证书名称"

    ELB_LBL_LISTENER_PRIVATE_KEY:
      en: "Private Key"
      zh: "私钥"

    ELB_LBL_LISTENER_PUBLIC_KEY:
      en: "Public Key Certificate"
      zh: "公钥"

    ELB_LBL_LISTENER_CERTIFICATE_CHAIN:
      en: "Certificate Chain"
      zh: "认证链"

    ELB_HEALTH_CHECK:
      en: "Health Check"
      zh: "健康度检查"

    ELB_HEALTH_CHECK_DETAILS:
      en: "Health Check Configuration"
      zh: "健康度检查配置"

    ELB_PING_PROTOCOL:
      en: "Ping Protocol"
      zh: "Ping协议"

    ELB_PING_PORT:
      en: "Ping\tPort"
      zh: "Ping端口"

    ELB_PING_PATH:
      en: "Ping Path"
      zh: "Ping路径"

    ELB_HEALTH_CHECK_INTERVAL:
      en: "Health Check Interval"
      zh: "健康度检查间隔"

    ELB_IDLE_TIMEOUT:
      en: "Idle Connection Timeout"
      zh: "空闲连接超时"

    ELB_HEALTH_CHECK_INTERVAL_SECONDS:
      en: "Seconds"
      zh: "秒"

    ELB_HEALTH_CHECK_RESPOND_TIMEOUT:
      en: "Response Timeout"
      zh: "响应超时"

    ELB_HEALTH_THRESHOLD:
      en: "Healthy Threshold"
      zh: "健康界限"

    ELB_UNHEALTH_THRESHOLD:
      en: "Unhealthy Threshold"
      zh: "不健康界限"

    ELB_AVAILABILITY_ZONE:
      en: "Availability Zones"
      zh: "可用区域"

    ELB_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    ELB_DNS_NAME:
      en: "DNS"
      zh: "域名"

    ELB_HOST_ZONE_ID:
      en: "Hosted Zone ID"
      zh: "Hosted Zone ID"

    ELB_CROSS_ZONE:
      en: "Cross-zone Load Balancing"
      zh: "Cross-zone Load Balancing"

    ELB_CONNECTION_DRAIN:
      en: "Connection Draining"
      zh: "连接丢失"

    ELB_ELB_PROTOCOL:
      en: "Load Balancer Protocol"
      zh: "负载均衡器协议"

    PORT:
      en: "Port"
      zh: "端口"

    ELB_INSTANCES:
      en: "Instances"
      zh: "实例"

    ELB_HEALTH_INTERVAL_VALID:
      en: "Response timeout must be less than the health check interval value"
      zh: "响应超时必须小于健康检查周期"

    ELB_CONNECTION_DRAIN_TIMEOUT_INVALID:
      en: "Timeout must be an integer between 1 and 3600"
      zh: "超市必须为1到3600的整数"

    ELB_TIP_CLICK_TO_SELECT_ALL:
      en: "Click to select all"
      zh: "单击全选"

    ELB_TIP_REMOVE_LISTENER:
      en: "Remove listener"
      zh: "移除侦听器"

    ELB_TIP_25_80_443OR1024TO65535:
      en: "25, 80, 443 or 1024 - 65535"
      zh: "25, 80, 443 or 1024 - 65535"

    ELB_TIP_1_65535:
      en: "1 - 65535"
      zh: "1 - 65535"

    ELB_TIP_CLICK_TO_READ_RELATED_AWS_DOCUMENT:
      en: "Click to read related AWS document"
      zh: "单击阅读相关 AWS 文档"

    ELB_CERT_REMOVE_CONFIRM_TITLE:
      en: "Confirm to Delete SSL Certificate"
      zh: "确认删除 SSL 证书"

    ELB_CERT_REMOVE_CONFIRM_MAIN:
      en: "Do you confirm to delete "
      zh: "您确认要删除"

    ELB_CERT_REMOVE_CONFIRM_SUB:
      en: "Load Balancer currently using this server certificate will have errors."
      zh: "正在使用此证书的负载均衡将会出错"

    ASG_SUMMARY:
      en: "Auto Scaling Group Summary"
      zh: "Auto Scaling 组摘要"

    ASG_DETAILS:
      en: "Auto Scaling Group Details"
      zh: "Auto Scaling 组配置"

    ASG_NAME:
      en: "Auto Scaling Group Name"
      zh: "Auto Scaling 组名称"

    ASG_REQUIRED:
      en: "Required"
      zh: "必须"

    ASG_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    ASG_MIN_SIZE:
      en: "Minimum Size"
      zh: "最小数量"

    ASG_MAX_SIZE:
      en: "Maximum Size"
      zh: "最大数量"

    ASG_DESIRE_CAPACITY:
      en: "Desired Capacity"
      zh: "期望数量"

    ASG_COOL_DOWN:
      en: "Default Cooldown"
      zh: "冷却时间"

    ASG_INSTANCE:
      en: "Instance"
      zh: "实例"

    ASG_DEFAULT_COOL_DOWN:
      en: "Default Cooldown"
      zh: "默认冷却时间"

    ASG_UNIT_SECONDS:
      en: "Seconds"
      zh: "秒"

    ASG_UNIT_MINS:
      en: "Minutes"
      zh: "分"

    ASG_HEALTH_CHECK_TYPE:
      en: "Health Check Type"
      zh: "健康度检查类型"

    ASG_HEALTH_CHECK_CRACE_PERIOD:
      en: "Health Check Grace Period"
      zh: "健康度检查时间"

    ASG_POLICY:
      en: "Policy"
      zh: "策略"

    ASG_HAS_ELB_WARN:
      en: "You need to connect this auto scaling group to a load balancer to enable this option."
      zh: "你需要连接AutoScaling组和一个负载均衡器来启动此选项"

    ASG_ELB_WARN:
      en: "If the calls to Elastic Load Balancing health check for the instance returns any state other than InService, Auto Scaling marks the instance as Unhealthy. And if the instance is marked as Unhealthy, Auto Scaling starts the termination process for the instance."
      zh: "只要弹性负载均衡的健康检查返回非正常服务的状态, Auto Scaling 组将此实例标记为不健康。 且一旦一个实例被标记为不健康, Auto Scaling 组将结束此实例。"

    ASG_TERMINATION_POLICY:
      en: "Termination Policy"
      zh: "结束策略"

    ASG_POLICY_TLT_NAME:
      en: "Policy Name"
      zh: "策略名称"

    ASG_POLICY_TLT_ALARM_METRIC:
      en: "Alarm Metric"
      zh: "警告准则"

    ASG_POLICY_TLT_THRESHOLD:
      en: "Threshold"
      zh: "界限"

    ASG_POLICY_TLT_PERIOD:
      en: "Evaluation Period x Periods"
      zh: "评估时间"

    ASG_POLICY_TLT_ACTION:
      en: "Action Trigger"
      zh: "触发动作"

    ASG_POLICY_TLT_ADJUSTMENT:
      en: "Adjustment"
      zh: "调整"

    ASG_POLICY_TLT_EDIT:
      en: "Edit Scaling Policy"
      zh: "编辑策略"

    ASG_POLICY_TLT_REMOVE:
      en: "Remove Scaling Policy"
      zh: "删除策略"

    ASG_BTN_ADD_SCALING_POLICY:
      en: "Add Scaling Policy"
      zh: "添加扩展策略"

    ASG_LBL_NOTIFICATION:
      en: "Notification"
      zh: "通知"

    ASG_LBL_SEND_NOTIFICATION_D:
      en: "Send notification via SNS topic"
      zh: "通过SNS发送通知"

    ASG_LBL_SEND_NOTIFICATION:
      en: "Send notification via SNS topic for:"
      zh: "通过SNS发送通知"

    ASG_LBL_SUCCESS_INSTANCES_LAUNCH:
      en: "Successful instance launch"
      zh: "运行实例成功"

    ASG_LBL_FAILED_INSTANCES_LAUNCH:
      en: "Failed instance launch"
      zh: "运行实例失败"

    ASG_LBL_SUCCESS_INSTANCES_TERMINATE:
      en: "Successful instance termination"
      zh: "终止实例成功"

    ASG_LBL_FAILED_INSTANCES_TERMINATE:
      en: "Failed instance termination"
      zh: "终止实例失败"

    ASG_LBL_VALIDATE_SNS:
      en: "Validating a configured SNS Topic"
      zh: "验证SNS主题"

    ASG_MSG_NO_NOTIFICATION_WARN:
      en: "No notification configured for this auto scaling group"
      zh: "没有设置Notification Configuration"

    ASG_MSG_SNS_WARN:
      en: "There is no SNS subscription set up yet. Go to Stack Property to set up SNS subscription so that you will get the notification."
      zh: "现在SNS还没有设置订阅信息，请去Stack属性框设置，以便收到通知"

    ASG_MSG_DROP_LC:
      en: "Drop AMI from Resource Panel to create Launch Configuration"
      zh: "请拖拽AMI来建立启动配置"

    ASG_TERMINATION_EDIT:
      en: "Edit Termination Policy"
      zh: "编辑终止策略"

    ASG_TERMINATION_TEXT_WARN:
      en: "You can either specify any one of the policies as a standalone policy, or you can list multiple policies in an ordered list. The policies are executed in the order they are listed."
      zh: "你能选择最少一种策略，策略执行顺序是从上到下"

    ASG_TERMINATION_MSG_DRAG:
      en: "Drag to sort policy"
      zh: "拖拽以便调整顺序"

    OLDESTINSTANCE:
      en: "OldestInstance"
      zh: "最旧的实例"

    NEWESTINSTANCE:
      en: "NewestInstance"
      zh: "最新的实例"

    OLDESTLAUNCHCONFIGURATION:
      en: "OldestLaunchConfiguration"
      zh: "最旧的启动配置"

    CLOSESTTONEXTINSTANCEHOUR:
      en: "ClosestToNextInstanceHour"
      zh: "下一个实例时钟"

    ASG_ADD_POLICY_TITLE_ADD:
      en: "Add"
      zh: "添加"

    ASG_ADD_POLICY_TITLE_EDIT:
      en: "Edit"
      zh: "编辑"

    ASG_ADD_POLICY_TITLE_CONTENT:
      en: "Scaling Policy"
      zh: "扩展策略"

    ASG_ADD_POLICY_ALARM:
      en: "Alarm"
      zh: "警报"

    ASG_ADD_POLICY_WHEN:
      en: "When"
      zh: "当"

    ASG_ADD_POLICY_IS:
      en: "is"
      zh: "是"

    ASG_ADD_POLICY_FOR:
      en: "for"
      zh: "持续"

    ASG_ADD_POLICY_PERIOD:
      en: "periods of"
      zh: "周期"

    ASG_ADD_POLICY_SECONDS:
      en: "minutes, enter ALARM state."
      zh: "分时，进入警报状态"

    ASG_ADD_POLICY_START_SCALING:
      en: "Start scaling activity when in"
      zh: "执行扩展活动，当处于"

    ASG_ADD_POLICY_STATE:
      en: "state."
      zh: "状态"

    ASG_ADD_POLICY_SCALING_ACTIVITY:
      en: "Scaling Activity"
      zh: "扩展活动"

    ASG_ADD_POLICY_ADJUSTMENT:
      en: "Adjust number of instances by"
      zh: "通过以下方式调整"

    ASG_ADD_POLICY_ADJUSTMENT_OF:
      en: "of"
      zh: "数量"

    ASG_ADD_POLICY_ADJUSTMENT_CHANGE:
      en: "Change in Capacity"
      zh: "数量改变"

    ASG_ADD_POLICY_ADJUSTMENT_EXACT:
      en: "Exact Capacity"
      zh: "精确数量"

    ASG_ADD_POLICY_ADJUSTMENT_PERCENT:
      en: "Percent Change in Capacity"
      zh: "数量百分比"

    ASG_ADD_POLICY_ADVANCED:
      en: "Advanced"
      zh: "高级"

    ASG_ADD_POLICY_ADVANCED_ALARM_OPTION:
      en: "Alarm Options"
      zh: "警报选项"

    ASG_ADD_POLICY_ADVANCED_STATISTIC:
      en: "Statistic"
      zh: "统计方式"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_AVG:
      en: "Average"
      zh: "平均"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_MIN:
      en: "Minimum"
      zh: "最小"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_MAX:
      en: "Maximum"
      zh: "最大"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_SAMPLE:
      en: "SampleCount"
      zh: "抽样计算"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_SUM:
      en: "Sum"
      zh: "总计"

    ASG_ADD_POLICY_ADVANCED_SCALING_OPTION:
      en: "Scaling Options"
      zh: "扩展选项"

    ASG_ADD_POLICY_ADVANCED_COOLDOWN_PERIOD:
      en: "Cooldown Period"
      zh: "冷却周期"

    ASG_ADD_POLICY_ADVANCED_TIP_COOLDOWN_PERIOD:
      en: "The amount of time, in seconds, after a scaling activity completes before any further trigger-related scaling activities can start. If not specified, will use auto scaling group's default cooldown period."
      zh: "两个扩展活动之间的冷却时间(秒)，如果不提供，则使用AWS默认时间"

    ASG_ADD_POLICY_ADVANCED_MIN_ADJUST_STEP:
      en: "Minimum Adjust Step"
      zh: "最小调整数量"

    ASG_ADD_POLICY_ADVANCED_TIP_MIN_ADJUST_STEP:
      en: "Changes the DesiredCapacity of the Auto Scaling group by at least the specified number of instances."
      zh: "调整期望数量时的最小实例数量"

    ASG_TIP_CLICK_TO_SELECT:
      en: "Click to select"
      zh: "单击选择"

    ASG_TIP_YOU_CAN_ONLY_ADD_25_SCALING_POLICIES:
      en: "You can only add 25 scaling policies"
      zh: "您最多只能添加 25 条规则"

    ASG_ARN:
      en: "Auto Scaling Group ARN"
      zh: "Auto Scaling 组 ARN"

    LC_TITLE:
      en: "Launch Configuration"
      zh: "启动配置"

    LC_NAME:
      en: "Name"
      zh: "名称"

    LC_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    RT_ASSOCIATION:
      en: "This is an association of "
      zh: "路由表关联线: "

    RT_ASSOCIATION_TO:
      en: "to"
      zh: "到"

    RT_NAME:
      en: "Name"
      zh: "名称"

    RT_LBL_ROUTE:
      en: "Routes"
      zh: "路由规则"

    RT_LBL_MAIN_RT:
      en: "Main Route Table"
      zh: "主路由表"

    RT_SET_MAIN:
      en: "Set as Main Route Table"
      zh: "设置为主路由表"

    RT_TARGET:
      en: "Target"
      zh: "路由对象"

    RT_LOCAL:
      en: "local"
      zh: "本地"

    RT_DESTINATION:
      en: "Destination"
      zh: "数据包目的地"

    RT_ID:
      en: "Route ID"
      zh: "路由表ID"

    RT_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    RT_TIP_ACTIVE:
      en: "Active"
      zh: "活跃的"

    RT_TIP_BLACKHOLE:
      en: "Blackhole"
      zh: "黑洞"

    RT_TIP_PROPAGATED:
      en: "Propagated"
      zh: "已传送"

    DBPG_RESMANAGER_FILTER:
      en: "Filter DB Engine by family name"
      zh: "按家族名过滤数据库引擎"

    DBPG_SET_FAMILY:
      en: "Family"
      zh: "家族"

    DBPG_SET_NAME:
      en: "Parameter Group Name"
      zh: "参数组名"

    DBPG_CONFIRM_RESET_1:
      en: "Do you confirm to reset all parameters for "
      zh: "您确定要重置"

    DBPG_CONFIRM_RESET_2:
      en: " to their defaults?"
      zh: "的所有参数为默认吗?"

    DBPG_FILTER_BY_NAME:
      en: "Filter by Parameter Name"
      zh: "通过参数名称过滤"

    DBPG_APPLY_IMMEDIATELY_1:
      en: "Changes will apply "
      zh: "修改将"

    DBPG_APPLY_IMMEDIATELY_2:
      en: "immediately"
      zh: "立即生效"

    DBPG_APPLY_IMMEDIATELY_3:
      en: "after rebooting"
      zh: "在重启后生效"

    DBPG_SET_DESC:
      en: "Description"
      zh: "描述"

    DBINSTANCE_TIT_DETAIL:
      en: "DB Instance Detail"
      zh: "数据库实例详情"

    DBINSTANCE_APP_DBINSTANCE_ID:
      en: "DB Instance Identifier"
      zh: "数据库实例标识符"

    ENDPOINT:
      en: "Endpoint"
      zh: "终端节点"

    DBINSTANCE_STATUS:
      en: "Status"
      zh: "状态"

    ENGINE:
      en: "Engine"
      zh: "引擎"

    DBINSTANCE_AUTO_UPGRADE:
      en: "Auto Minor Version Upgrade"
      zh: "自动版本升级"

    DBINSTANCE_CLASS:
      en: "DB Instance Class"
      zh: "数据库实例类"

    DBINSTANCE_IOPS:
      en: "IOPS"
      zh: "IOPS"

    DBINSTANCE_STORAGE_REQUIRE_10_RATIO:
      en: "Requires a fixed ratio of 10 IOPS / GB storage"
      zh: "IOPS要求为存储的10倍"

    DBINSTANCE_STORAGE_IOPS_3_10_RATIO:
      en: "Supports IOPS / GB ratios between 3 and 10"
      zh: "IOPS要求为存储的3到10倍"

    DBINSTANCE_STORAGE:
      en: 'Storage'
      zh: "存储"

    DBINSTANCE_STORAGE_TYPE:
      en: 'Storage Type'
      zh: "存储类型"

    DBINSTANCE_USERNAME:
      en: "Username"
      zh: "用户名"

    DBINSTANCE_READ_REPLICAS:
      en: "Read Replicas"
      zh: "读取复制"

    DBINSTANCE_REPLICAS_SOURCE:
      en: "Read Replicas Source"
      zh: "读取复制源"

    DBINSTANCE_DBCONFIG:
      en: "Database Config"
      zh: "数据库配置"

    DATABASE_NAME:
      en: "DB instance name"
      zh: "数据库名称"

    DBINSTANCE_PORT:
      en: "Database Port"
      zh: "数据库端口"

    DBINSTANCE_OG:
      en: "Option Group"
      zh: "选项组"

    DBINSTANCE_PG:
      en: "Parameter Group"
      zh: "参数组"

    DBINSTANCE_NETWORK_AVAILABILITY:
      en: "Network & Availability"
      zh: "网络与可用性"

    DBINSTANCE_SUBNETGROUP:
      en: "Subnet Group"
      zh: "子网组"

    DBINSTANCE_SQLSERVER_MIRROR_TIP:
      en: "SQL Server Mirroring(Multi-AZ) is controlled by Option Group. To make sure this DB instance has mirroring, please edit its Option Group."
      zh: "SQL Server Mirroring(多 AZ)被选项组控制．要确保此数据库实例有Mirroring，请编辑它的选项组"

    DBINSTANCE_MUTIL_AZ_DEPLOY:
      en: "Multi-AZ Deployment"
      zh: "多 AZ 部署"

    DBINSTANCE_PREFERRED_ZONE:
      en: "Preferred Availability Zone"
      zh: "优先可用区域"

    DBINSTANCE_SECONDARY_ZONE:
      en: "Secondary Availability Zone"
      zh: "第二可用区域"

    DBINSTANCE_PUBLIC_ACCESS:
      en: "Publicly Accessible"
      zh: "公共可访问性"

    DBINSTANCE_LICENSE_MODEL:
      en: "License Model"
      zh: "许可模式"

    DBINSTANCE_DB_ENGINE_VERSION:
      en:"DB Engine Version"
      zh: "数据库引擎版本"

    DBINSTANCE_DB_INSTANCE_CLASS:
      en: "DB Instance Class"
      zh: "数据库实例类"

    DBINSTANCE_SOMETHING_ERROR:
      en: "Some error has occurred. Please try again."
      zh: "出错了。请重试。"

    DBINSTANCE_OPTION_GROUP:
      en: "Option Group"
      zh: "选项组"

    DBINSTANCE_SUBNETGROUP_NOT_SETUP:
      en: "Subnet Group %s is not correctly set up yet. Assign %s to at least 2 availability zones."
      zh: "子网组设置不正确, 分配 %s 至少两个可用区域"

    DBINSTANCE_BACKUP_MAINTENANCE:
      en: "Backup & Maintenance"
      zh: "备份与管理"

    DBINSTANCE_AUTOBACKUP:
      en: "Automated Backups"
      zh: "自动备份"

    DBINSTANCE_LAST_RESTORE:
      en: "Latest Restore Time"
      zh: "最新还原时间"

    DBINSTANCE_SECURITY_GROUP:
      en: "Security Group"
      zh: "安全组"

    DBINSTANCE_SUBNET_GROUP_NAME:
      en: "DB Subnet Group Name"
      zh: "数据库子网组名称"

    DBINSTANCE_SUBNET_GROUP_DESC:
      en: "DB Subnet Group Description"
      zh: "数据库子网组描述"

    DBINSTANCE_SUBNET_GROUP_STATUS:
      en: "Status"
      zh: "状态"

    DBINSTANCE_SUBNET_GROUP_MEMBERS:
      en: "Members"
      zh: "成员"

    DBINSTANCE_PROMOTE_CONFIRM_MAJOR:
      en: "The following steps show the general process for promoting a read replica to a Single-AZ DB instance."
      zh: "以下几步展示了将一个只读副本提升为单 AZ 的数据库实例的一般过程"

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_1:
      en: "Stop any transactions from being written to the read replica source DB instance, and then wait for all updates to be made to the read replica."
      zh: "停止只读副本源数据库的所有写入操作, 并等待只读副本完成全部更新"

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_2:
      en: "To be able to make changes to the read replica, you must the set the read_only parameter to 0 in the DB parameter group for the read replica."
      zh: "要修改只读副本, 您必须在只读副本的参数组里将 read_only 参数设置为 0"

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_3:
      en: "Perform all needed DDL operations, such as creating indexes, on the read replica."
      zh: "然后进行所有的 DDL 操作, 比如在只读副本上创建索引"

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_4:
      en: "Promote the read replica."
      zh: "提升只读副本"

    DBINSTANCE_PROMOTE_NOTE:
      en: "Note"
      zh: "注"

    DBINSTANCE_PROMOTE_NOTE_CONTENT:
      en: "The promotion process takes a few minutes to complete. When you promote a read replica, replication is stopped and the read replica is rebooted. When the reboot is complete, the read replica is available as a Single-AZ DB instance."
      zh: "提升的过程将会花费几分钟。提升只读副本的时候, 副本停止并重启, 重启完成后, 只读副本将变成可用的单区域数据库实例。"

    DBINSTANCE_PROMOTE_LINK_TEXT:
      en: "Read AWS Document"
      zh: "查看 AWS 相关文档"

    DBINSTANCE_NOT_AVAILABLE:
      en: "This DB instance is not in available status. To apply modification made for this instance, wait for its status to be available."
      zh: "此数据库不在可用状态，请等待状态可用后应用改变。"

    DBINSTANCE_READ_REPLICA:
      en: "Promote Read Replica"
      zh: "提升只读副本"

    DBINSTANCE_CANCEL_PROMOTE:
      en: "Cancel Promote"
      zh: '取消提升'

    DBINSTANCE_APPLY_IMMEDIATELY:
      en: "Apply Immediately"
      zh: "立即应用"

    DBINSTANCE_DETAILS:
      en: "DB Instance Details"
      zh: "数据库实例详细"

    DBINSTANCE_APPLY_IMMEDIATELY_LINK_TOOLTIP:
      en: "Click to read AWS documentation on modifying DB instance using Apply Immediately."
      zh: "点击阅读 AWS 关于立即应用数据库实例修改的文档"

    DBINSTANCE_MASTER_DB_INSTANCE:
      en: "Master DB Instance"
      zh: "主要数据库实例"

    DBINSTANCE_DBSNAPSHOT_ID:
      en: "DB Snapshot ID"
      zh: "数据库快照 ID"

    DBINSTANCE_DBSNAPSHOT_SIZE:
      en: "DB Snapshot Size"
      zh: "数据库快照大小"

    DBINSTANCE_PENDING_APPLY:
      en: "(Pending Apply)"
      zh: "(等待应用)"

    DBINSTANCE_NAME:
      en: "DB Instance Name"
      zh: "数据库实例名称"

    DBINSTANCE_AUTO_MINOR_VERSION_UPDATE:
      en: "Auto Minor Version Update"
      zh: "自动版本升级"

    DBINSTANCE_ALLOCATED_STORAGE:
      en: "Allocated Storage"
      zh: "分配存储"

    DBINSTANCE_SCALLING_NOT_SUPPORT:
      en: "Scaling storage after launch a DB Instance is currently not supported for SQL Server."
      zh: "启动数据库实例后伸缩存储目前不支持 SQL 数据库"

    DBINSTANCE_CURRENT_ALLOCATED_STORAGE:
      en: "Current Allocated Storage: "
      zh: "目前分配的存储:"

    DBINSTANCE_USE_PROVISIONED_IOPS:
      en: "Use Provisioned IOPS"
      zh: "使用预配置 IOPS"

    DBINSTANCE_PROVISIONED_IOPS:
      en: "Provisioned IOPS"
      zh: "预配置 IOPS"

    DBINSTANCE_IOPS_AVAILABILITY_IMPACT:
      en: "When you initiate a storage type conversion between IOPS and standard storage, your DB Instance will have an availability impact for a few minutes."
      zh: "当您进行 IOPS 与标准存储之间的类型转换时, 您的数据库实例将会有几分钟受影响"

    DBINSTANCE_MASTER_USERNAME:
      en: "Master Username"
      zh: "主用户名"

    DBINSTANCE_MASTER_PASSWORD:
      en: "Master Password"
      zh: "主密码"

    DBINSTANCE_DATABASE_CONFIG:
      en: "Database Config"
      zh: "数据库配置"

    DBINSTANCE_NOT_READY:
      en: "Not Ready"
      zh: "未就绪"

    DBINSTANCE_DATABASE_NAME:
      en: "Database Name"
      zh: "数据库名称"

    DBINSTANCE_DATABASE_PORT:
      en: "Database Port"
      zh: "数据库端口"

    DBINSTANCE_CHARACTER_SET_NAME:
      en: "Character Set Name"
      zh: "字符集名称"

    DBINSTANCE_NETWORK_AZ_DEPLOYMENT:
      en: "Network & AZ Deployment"
      zh: "网络和可用区部署"

    DBINSTANCE_PUBLICLY_ACCESSIBLE:
      en: "Publicly Accessible"
      zh: "可公网访问"

    DBINSTANCE_BACKUP_OPTION:
      en: 'Backup Options'
      zh: "备份选项"

    DBINSTANCE_REPLICA_MUST_ENABLE_AUTOMATIC_BACKUPS:
      en: "DB instance serving as replication source must enable automatic backups"
      zh: "作为复制源的数据库实例必须开启自动备份"

    DBINSTANCE_ENABLE_AUTOMATIC_BACKUP:
      en: "Enable Automatic Backups"
      zh: "启用自动备份"

    DBINSTANCE_BACKUP_RETENTION_PERIOD:
      en: "Backup Retention Period"
      zh: "备份保留周期"

    DBINSTANCE_BACK_RETANTION_PERIOD_DAY:
      en: "day(s)"
      zh: "天"

    DBINSTANCE_BACKUP_WINDOW:
      en: "Backup Window"
      zh: "备份窗口"

    DBINSTANCE_NO_PREFERENCE:
      en: "No Preference"
      zh: "无偏好设置"

    DBINSTANCE_SELECT_WINDOW:
      en: "Select Window"
      zh: "选择窗口"

    DBINSTANCE_START_TIME:
      en: "Start Time:"
      zh: "开始时间:"

    DBINSTANCE_DURATION:
      en: "Duration: "
      zh: "持续:"

    DBINSTANCE_BACKUP_DURATION_HOUR:
      en: "hour(s)"
      zh: "小时"

    DBINSTANCE_CURRENT_BACKUP_WINDOW:
      en: "Current Backup Window: "
      zh: "当前备份窗口:"

    DBINSTANCE_MAINTENANCE_OPTION:
      en: "Maintenance Options"
      zh: "维护选项"

    DBINSTANCE_MAINTENANCE_WINDOW:
      en: "Maintenance Window"
      zh: "维护窗口"

    DBINSTANCE_MAINTENANCE_START_DAY:
      en: "Start Day"
      zh: "开始日"

    WEEKDAY_MONDAY:
      en: "Monday"
      zh: "星期一"

    WEEKDAY_TUESDAY:
      en: "Tuesday"
      zh: "星期二"

    WEEKDAY_WEDNESDAY:
      en: "Wednesday"
      zh: "星期三"

    WEEKDAY_THURSDAY:
      en: "Thursday"
      zh: "星期四"

    WEEKDAY_FRIDAY:
      en: "Friday"
      zh: "星期五"
    WEEKDAY_SATURDAY:
      en: "Saturday"
      zh: "星期六"

    WEEKDAY_SUNDAY:
      en: "Sunday"
      zh: "星期日"

    SELECT_SNS_TOPIC:
      en: "Select SNS Topic"
      zh: "选择 SNS 主题"

    ASG_POLICY_CPU:
      en: "CPU Utilization"
      zh: "CPU利用率"

    ASG_POLICY_DISC_READS:
      en: "Disk Reads"
      zh: "磁盘读取"

    ASG_POLICY_DISK_READ_OPERATIONS:
      en: "Disk Read Operations"
      zh: "磁盘读取操作"

    ASG_POLICY_DISK_WRITES:
      en: "Disk Writes"
      zh: "磁盘写入"

    ASG_POLICY_DISK_WRITE_OPERATIONS:
      en: "Disk Write Operations"
      zh: "磁盘写入操作"

    ASG_POLICY_NETWORK_IN:
      en: "Network In"
      zh: "网络流入"

    ASG_POLICY_NETWORK_OUT:
      en: "Network Out"
      zh: "网络流出"

    ASG_POLICY_STATUS_CHECK_FAILED_ANY:
      en: "Status Check Failed (Any)"
      zh: "状态检查失败(所有)"

    ASG_POLICY_STATUS_CHECK_FAILED_INSTANCE:
      en: "Status Check Failed (Instance)"
      zh: "状态检查失败(实例)"

    ASG_POLICY_STATUS_CHECK_FAILED_SYSTEM:
      en: "Status Check Failed (System)"
      zh: "状态检查失败(系统)"

    ASG_ADJUST_TOOLTIP_CHANGE:
      en: "Increase or decrease existing capacity by integer you input here. A positive value adds to the current capacity and a negative value removes from the current capacity."
      zh: "根据您输入的数字增减当前值, 若为正值会与当前值相加, 负值则会与当前值相减"

    ASG_ADJUST_TOOLTIP_EXACT:
      en: "Change the current capacity of your Auto Scaling group to the exact value specified."
      zh: "修改Auto Scaling 组的当前值为您指定的值"

    ASG_ADJUST_TOOLTIP_PERCENT:
      en: "Increase or decrease the desired capacity by a percentage of the desired capacity. A positive value adds to the current capacity and a negative value removes from the current capacity"
      zh: "根据百分比来增减当前值, 若为正值会与当前值相加, 负值则会与当前值相减"

    AZ_CANNOT_EDIT_EXISTING_AZ:
      en: "Cannot edit existing availability zone. However, newly created availability zone is editable."
      zh: "无法编辑已存在的 AZ, 但新建的 AZ 可以编辑"

    CGW_IP_VALIDATE_REQUIRED:
      en: "IP Address is required."
      zh: "IP 地址为必填"

    CGW_IP_VALIDATE_REQUIRED_DESC:
      en: "Please provide a IP Address of this Customer Gateway."
      zh: "请提供一个此自定义网关的 IP 地址"

    CGW_IP_VALIDATE_INVALID:
      en: "%s  is not a valid IP Address."
      zh: "%s 不是有效的 IP 地址"

    CGW_IP_VALIDATE_INVALID_DESC:
      en: "Please provide a valid IP Address. For example, 192.168.1.1."
      zh: "请提供一个有效的 IP 地址, 比如: 192.168.1.1"

    CGW_IP_VALIDATE_INVALID_CUSTOM:
      en: "IP Address %s is invalid for customer gateway."
      zh: "IP 地址 %s 相对此网关无效"

    CGW_IP_VALIDATE_INVALID_CUSTOM_DESC:
      en: "The address must be static and can't be behind a device performing network address translation (NAT)."
      zh: "此地址必须为静态并且不能在 NAT 网络中"

    CGW_REMOVE_CUSTOM_GATEWAY:
      en: "Remove Customer Gateway"
      zh: "移除自定义网关"

    CONNECTION_ATTACHMENT_OF:
      en: "This is an attachment of %s to %s"
      zh: "%s 到 %s 的连接"

    CONNECTION_SUBNET_ASSO_PLACEMENT:
      en: "A Virtual Network Interface is placed in %s for %s to allow traffic be routed to this availability zone."
      zh: "一个为 %s 的虚拟网络接口被放到 %s ，允许流量被路由到此可用区域"

    ENI_ATTACHMENT_NAME:
      en: "Instance-ENI Attachment"
      zh: "实例-网络接口连接"

    ELB_SUBNET_ASSO_NAME:
      en: "Load Balancer-Subnet Association"
      zh: "负载均衡-子网连接"

    ELB_INTERNET_FACING:
      en: "Internet Facing"
      zh: "网络接口"

    ELB_INTERNAL:
      en: "Internal"
      zh: "内部"

    ELB_ENABLE_CROSS_ZONE_BALANCING:
      en: "Enable cross-zone load balancing"
      zh: "启用跨区域负载均衡"

    ELB_CONNECTION_DRAINING:
      en: "Enable Connection Draining"
      zh: "启用连接丢弃"

    ELB_CONNECTION_TIMEOUT:
      en: "Timeout"
      zh: "超时"

    ELB_CONNECTION_SECONDS:
      en: "Seconds"
      zh: "秒"

    ELB_LOAD_BALENCER_PROTOCOL:
      en: "Load Balancer Protocol"
      zh: "负载均衡协议"

    ELB_INSTANCE_PROTOCOL:
      en: "Instance Protocol"
      zh: "实例协议"

    ENI_NETWORK_INTERFACE_DETAIL:
      en: "Network Interface Details"
      zh: "网络接口详情"

    ENI_NETWORK_INTERFACE_SUMMARY:
      en: "Network Interface Summary"
      zh: "网络接口概要"

    ENI_NETWORK_INTERFACE_GROUP_MEMBERS:
      en: "Network Interface Group Members"
      zh: "网络接口群组成员"

    ENI_CREATE_AFTER_APPLYING_UPDATES:
      en: "Create after applying updates"
      zh: "应用更新后创建"

    ENI_DELETE_AFTER_APPLYING_UPDATES:
      en: "Delete after applying updates"
      zh: "应用更新后删除"

    INSTANCE_ROOT_DEVICE:
      en: "Root Device"
      zh: "根设备"

    INSTANCE_WATCH_LINK_TEXT:
      en: "Amazon Cloud Watch Product Page"
      zh: "亚马逊 Cloud Watch 产品页"

    INSTANCE_USERDATA_DISABLED_TO_INSTALL_VISUALOPS:
      en: "User Data is disabled to allow installing OpsAgent for VisualOps."
      zh: "用户数据已禁用以安装 VisualOps 代理"

    INSTANCE_VIEW_AGENT_USER_DATA_URL_TEXT:
      en: "View content"
      zh: "查看内容"

    INSTANCE_EBS_OPTIMIZED:
      en: "EBS Optimized"
      zh: "EBS 优化的"

    INSTANCE_IOPS:
      en: "IOPS"
      zh: "IOPS"

    LC_DELETE_CUSTUME_KEY_PAIR_CONFIRM:
      en: "<p class='modal-text-major'>Are you sure to delete %s?</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
      zh: "<p class='modal-text-major'>您确定要删除 %s 吗?</p><p class='modal-text-minor'>使用此密钥对的资源将自动改为使用默认密钥对</p>"

    MISSING_RESOURCE_UNAVAILABLE:
      en: "Resource Unavailable"
      zh: "资源不可用"

    RTB_ALLOW_PROPAGATION:
      en: "Allow Propagation"
      zh: "允许传播"

    RTB_REMOVE_VPC_PEER_ROUTE:
      en: "Currently not supported. <a>Remove this route.</a>"
      zh: "当前不支持，<a>删除该路由</a>"

    RTB_CIDR_BLOCK_REQUIRED:
      en: "CIDR Block is required"
      zh: "CIDR 块为必填"

    RTB_CIDR_BLOCK_REQUIRED_DESC:
      en: "Please provide a IP ranges for this route."
      zh: "请为此路由提供一个 IP 段"

    RTB_CIDR_BLOCK_INVALID:
      en: "%s is not a valid form of CIDR Block"
      zh: "%s 不是有效的 CIDR 块"

    RTB_CIDR_BLOCK_INVALID_DESC:
      en: "Please provide a valid IP range. For example, 10.0.0.1/24."
      zh: "请提供有效的 IP 区间, 如: 10.0.0.1/24"

    RTB_CIDR_BLOCK_CONFLICTS:
      en: "%s conflicts with other route."
      zh: "%s 同其他路由冲突"

    RTB_CIDR_BLOCK_CONFLICTS_DESC:
      en: "Please choose a CIDR block not conflicting with existing route."
      zh: "请选择一个不与其他已存在路由冲突的 CIDR 区块"

    RTB_CIDR_BLOCK_CONFLICTS_LOCAL:
      en: "%s conflicts with local route."
      zh: "%s 与本地路由冲突"

    RTB_CIDR_BLOCK_CONFLICTS_LOCAL_DESC:
      en: "Please choose a CIDR block not conflicting with local route."
      zh: "请选择一个不与本地路由冲突的 CIDR 区块"

    SG_INSTANCE_SUMMARY:
      en: "Instance Summary"
      zh: "实例概要"

    SG_SERVER_GROUP_MEMBERS:
      en: "Server Group Members"
      zh: "服务器群组成员"

    SG_LAUNCH_AFTER_APPLYING_UPDATES:
      en: "Launch after applying updates"
      zh: "应用后启动"

    SG_TERMINATE_AFTER_APPLYING_UPDATE:
      en: "Terminate after applying updates"
      zh: "应用后终止"

    SG_UPDATE_INSTANCE_TYPE_DISABLED_FOR_INSTANCE_STORE:
      en: "Updating instance type is disabled for instances using instance store for root device."
      zh: "根设备使用实例存储的实例上的更新实例类型已被禁用"

    SG_AMAZON_CLOUD_WATCH_PRODUCT_PAGE:
      en: "Amazon Cloud Watch Product Page"
      zh: "亚马逊 Cloud Watch 产品页"

    SGLIST_DELETE_SG_CONFIRM_TITLE:
      en: "Are you sure you want to delete %s ?"
      zh: "您确定要删除 %s 吗?"

    SGLIST_DELETE_SG_CONFIRM_DESC:
      en: "The firewall settings of %s's member will be affected. Member only has this security group will be using DefaultSG."
      zh: "%s 的成员的防火墙设置将受到影响．使用该安全组的成员将使用 DefaultSG"

    SGLIST_DELETE_SG_TITLE:
      en: "Delete Security Group"
      zh: "删除安全组"

    SGRULE_SELECTED_CONNECTION_REFLECTS_FOLLOWING_SGR:
      en: "The selected connection reflects following security group rule(s);"
      zh: "选择的连接反映了下列安全组规则"

    STACK_SNS_SUBSCRIPTION:
      en: " SNS Subscription"
      zh: " SNS 订阅"

    STACK_SNS_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    STACK_SNS_PROTOCOL_HTTPS:
      en: "HTTPS"
      zh: "HTTPS"

    STACK_SNS_PROTOCOL_HTTP:
      en: "HTTP"
      zh: "HTTP"

    STACK_SNS_PROTOCOL_EMAIL:
      en: "Email"
      zh: "电子邮件"

    STACK_SNS_PROTOCOL_EMAIL_JSON:
      en: "Email - JSON"
      zh: "电子邮件 - JSON"

    STACK_SNS_PROTOCOL_SMS:
      en: "SMS"
      zh: "短信"

    STACK_SNS_PROTOCOL_APPLICATION:
      en: "Application"
      zh: "应用程序"

    STACK_SNS_PROTOCOL_AMAZON_SQS:
      en: "Amazon SQS"
      zh: "亚马逊 SQS"

    STACK_DELETE_NETWORK_ACL_TITLE:
      en: "Delete Network ACL"
      zh: "删除网络 ACL"

    STACK_DELETE_NETWORK_ACL_CONTENT:
      en: "Are you sure you want to delete %s"
      zh: "您确认要删除 %s"

    STACK_DELETE_NETWORK_ACL_DESC:
      en: "Subnets associated with %s will use DefaultACL."
      zh: "关联 %s 的子网将使用 DefaultACL"

    STATICSUB_VALIDATION_AMI_INFO_MISSING:
      en: "Ami info is missing, please reopen stack and try again."
      zh: "AMI 信息丢失，请重新打开 stack 重试"

    STATICSUB_VALIDATION_AMI_TYPE_NOT_SUPPORT:
      en: "Changing AMI platform is not supported. To use a %s AMI, please create a new instance instead."
      zh: "替换的 AMI 平台不支持．要使用 %s AMI，请创建一个新的实例以替换"

    STATICSUB_VALIDATION_AMI_INSTANCETYPE_NOT_VALID:
      en: "%s does not support previously used instance type %s. Please change another AMI."
      zh: "%s 不支持之前使用的实例类型 %s．请更换其他 AMI"

    SUBNET_CIDR_VALIDATION_REQUIRED:
      en: "CIDR block is required."
      zh: "CIDR 块必填"

    SUBNET_CIDR_VALIDATION_REQUIRED_DESC:
      en: "Please provide a subset of IP ranges of this VPC."
      zh: "请提供在此 VPC 的 IP 范围的一个子集"

    SUBNET_CIDR_VALIDATION_INVALID:
      en: "%s is not a valid form of CIDR block."
      zh: "%s 不是一个有效的 CIDR 块格式"

    SUBNET_CIDR_VALIDATION_INVALID_DESC:
      en: "Please provide a valid IP range. For example, 10.0.0.1/24."
      zh: "请提供一个有效的 IP 范围，例如，10.0.0.1/24"

    SUBNET_GROUP_DETAILS:
      en: "Subnet Groups Details"
      zh: "子网组详情"

    SUBNET_GROUP_NAME:
      en: "Name"
      zh: "名称"

    SUBNET_GROUP_DESCRIPTION:
      en: "Description"
      zh: "描述"

    SUBNET_GROUP_MEMBER:
      en: "Member"
      zh: "成员"

    VOLUME_DISABLE_IOPS_TOOLTIP:
      en: "Volume size must be at least 10 GB to use Provisioned IOPS volume type."
      zh: "要使用预置IOPS存储类型，存储大小必须至少为10GB"

    VPC_SELECTING_DEDICATED_DESC:
      en: "Selecting 'Dedicated' forces all instances launched into this VPC to run on single-tenant hardware."
      zh: "选择“专用“将强制所有此 VPC 内的实例运行在单租户硬件中。"

    VPC_SELECTING_DEDICATED_LINK_TEXT:
      en: "Additional changes will apply."
      zh: "这将会产生额外费用。"

    VPN_STACK_STATIC:
      en: "Static"
      zh: "静态"

    VPN_STACK_DYNAMIC:
      en: "Dynamic"
      zh: "动态"

    VPN_GATEWAY_VPN_DYNAMIC:
      en: " Since this VPN is connected to a Customer Gateway with dynamic routing, no configuration is necessary here."
      zh: " VPN 连接到使用动态路由的 CGW，因此无需配置"

    VPN_BLUR_CIDR_REQUIRED:
      en: "CIDR block is required."
      zh: "CIDR 块必填"

    VPN_BLUR_CIDR_REQUIRED_DESC:
      en: "Please provide a IP ranges for this IP Prefix. "
      zh: "请为此 IP 前缀提供一个 IP 范围"

    VPN_BLUR_CIDR_NOT_VALID_IP:
      en: "%s is not a valid form of CIDR block."
      zh: "%s 不是一个有效的 CIDR 块格式"

    VPN_BLUR_CIDR_NOT_VALID_IP_DESC:
      en: "Please provide a valid IP range. For example, 10.0.0.1/24."
      zh: "请提供一个有效的 IP 范围，例如，10.0.0.1/24"

    VPN_BLUR_CIDR_CONFLICTS_IP:
      en: "%s conflicts with other IP Prefix."
      zh: "%s 与其他 IP 前缀冲突"

    VPN_BLUR_CIDR_CONFLICTS_IP_DESC:
      en: "Please choose a CIDR block not conflicting with existing IP Prefix."
      zh: "请选择一个与其他 IP 前缀不冲突的 CIDR 块"

    VPN_REMOVE_CONNECTION:
      en: "Remove Connection"
      zh: "删除连接"

    RDS_LBL_REFRESH:
      en: "Refresh"
      zh: "刷新"

    RDS_LBL_CLOSE:
      en: "Close"
      zh: "关闭"

    LBL_CLOSE:
      en: "Close"
      zh: "关闭"

    RDS_NO_RECORDS_FOUND:
      en: "No records found."
      zh: "未发现记录"

    RDS_PROMOTE_REPLICA_WARNING:
      en: "The promotion process takes a few minutes to complete. When you promote a read replica, replication is stopped and the read replica is rebooted. When the reboot is complete, the read replica is available as a Single-AZ DB instance."
      zh: "提升过程需要花费几分钟完成，当提升一个只读副本时，复制会被停止，只读副本会重启。重启完成后，只读副本可用并独立成为一个单可用区域的数据库实例"

    RDS_READ_AWS_DOC:
      en: "Read AWS Document"
      zh: "阅读 AWS 文档"

    RDS_NO_BACKUP_TIP:
      en: "There is no available backup to use yet. Please try later."
      zh: "尚无可用备份，请稍后重试"

    RDS_RESTORE_DB_TIP:
      en: "You are creating a new DB Instance from a source DB Instance at a specified time. This new DB Instance will have the default DB Security Group and DB Parameter Groups."
      zh: "您正在从一个源数据库实例的指定时间创建新的数据库实例，此新实例将关联默认数据库安全组和数据库参数组"

    RDS_RESTORE_USE_LASTEST_TIME:
      en: "Use Latest Restorable Time"
      zh: "使用最近可还原时间"

    RDS_RESTORE_USE_CUSTOM_TIME:
      en: "Use Custom Restore Time"
      zh: "使用自定义还原时间"

    RDS_RESTORE:
      en: "Restore"
      zh: "还原"

    ###
    COMPONENT:
    ###

    CREATE_SNAPSHOT:
      en: "Create Snapshot"
      zh: "创建快照"

    SNAPSHOT_SET_NAME:
      en: "Snapshot Name"
      zh: "快照名称"

    SNAPSHOT_SET_NAME_TIP:
      en: "Enter the name of the snapshot that you will create."
      zh: "输入要创建的快照名称"

    SNAPSHOT_SOURCE_SNAPSHOT:
      en: "Source Snapshot"
      zh: "源快照"

    SNAPSHOT_SET_NEW_NAME:
      en: "New Snapshot Name"
      zh: "新快照名称"

    SNAPSHOT_DESTINATION_REGION:
      en: "Destination Region"
      zh: "目标地区"

    SNAPSHOT_SET_VOLUME:
      en: "Volume"
      zh: "卷"

    SNAPSHOT_SET_INSTANCE:
      en: "Instance"
      zh: "实例"

    INSTANCE_SNAPSHOT_SELECT:
      en: "Select DB instance from which to create snapshot"
      zh: "选择要创建快照的数据库实例"

    SNAPSHOT_SET_DESC:
      en: "Description"
      zh: "描述"

    VPC_TIP_ENTER_THE_NEW_SNAPSHOT_NAME:
      en: "Please fill with the name of the new snapshot you will create."
      zh: "请填写要创建的快照名称"

    SNAPSHOT_SET_DESC_TIP:
      en: "Fill in the Description"
      zh: "填写描述"

    DB_SNAPSHOT_DELETE_1:
      en: "Confirm to delete "
      zh: "确认删除 "

    DB_SNAPSHOT_DELETE_2:
      en: " selected "
      zh: " 选择的 "

    DB_SNAPSHOT_DELETE_3:
      en: " Snapshots"
      zh: " 快照"

    DB_SNAPSHOT_EMPTY:
      en: "There are no available DB instances here."
      zh: "尚无可用实例"

    DB_SNAPSHOT_ID:
      en: "DB Snapshot ID"
      zh: "数据库快照 ID"

    DB_SNAPSHOT_VPC_ID:
      en: "Vpc ID"
      zh: "VPC ID"

    DB_SNAPSHOT_ENGINE:
      en: "DB Engine"
      zh: "数据库引擎"

    DB_SNAPSHOT_LICENSE_MODEL:
      en: "License Model"
      zh: "许可模式"

    DB_SNAPSHOT_STATUS:
      en: "Status"
      zh: "状态"

    DB_SNAPSHOT_STORAGE:
      en: "DB Storage"
      zh: "数据库存储"

    DB_SNAPSHOT_CREATE_TIME:
      en: "Snapshot Creation Time"
      zh: "快照创建时间"

    DB_SNAPSHOT_SOURCE_REGION:
      en: "Source Region"
      zh: "源地区"

    DB_SNAPSHOT_INSTANCE_NAME:
      en: "DB Instance Name"
      zh: "数据库实例名称"

    DB_SNAPSHOT_TYPE:
      en: "Snapshot Type"
      zh: "快照类型"

    DB_SNAPSHOT_ENGINE_VERSION:
      en: "DB Engine Version"
      zh: "数据库引擎版本"

    DB_SNAPSHOT_MASTER_USERNAME:
      en: "Master Username"
      zh: "主用户名"

    OPTION_GROUP_NAME:
      en: "Option Group Name"
      zh: "选项组名称"

    DB_SNAPSHOT_INSTANCE_CREATE_TIME:
      en: "Instance Creation Name"
      zh: "实例创建名称"

    DB_DB_SUBGROUP_FAILED_FETCHING_TAGS:
      en: "Failed to fetch resource tags, please try again later."
      zh: "获取资源标签失败， 请稍后重试。"

    DB_SNAPSHOT_ACCOUNT_NUMBER_INVALID:
      en: "Please update your account number with numbers."
      zh: "请更新您的 Account Number 为数字"

    DB_CONFIRM_PROMOTE:
      en: "Confirm"
      zh: "确认"

    LBL_DELETING:
      en: "Deleting..."
      zh: "删除中..."

    LBL_DELETE:
      en: "Delete"
      zh: "删除"

    LBL_NAME:
      en: "Name"
      zh: "名称"

    LBL_CAPACITY:
      en: "Capacity"
      zh: "大小"

    LBL_STATUS:
      en: "Status"
      zh: "状态"

    LBL_DETAIL:
      en: "Detail"
      zh: "详情"

    LBL_DESC:
      en: "Description"
      zh: "描述"

    LBL_FILTER:
      en: "Filter: "
      zh: "过滤: "

    LBL_SORT_BY:
      en: "Sort by: "
      zh: "排序: "

    LBL_CREATING:
      en: "Creating..."
      zh: "创建中..."

    LBL_DOWNLOAD:
      en: "Download"
      zh: "下载"

    LBL_DOWNLOADING:
      en: "Downloading..."
      zh: "下载中..."

    LBL_VIEW:
      en: "View"
      zh: "查看"

    LBL_DUPLICATE:
      en: "Duplicate"
      zh: "复制"

    LBL_DUPLICATING:
      en: "Duplicating..."
      zh: "复制中..."

    LBL_RESET:
      en: "Reset"
      zh: "重置"

    LBL_RESETTING:
      en: "Resetting..."
      zh: "重置中..."

    LBL_CREATE:
      en: "Create"
      zh: "创建"

    LBL_IMPORT:
      en: "Import"
      zh: "导入"

    LBL_SUCCESS:
      en: "Success"
      zh: "成功"

    LBL_IMPORTING:
      en: "Importing..."
      zh: "导入中..."

    LBL_DISABLED:
      en: "Disabled"
      zh: "禁用"

    LBL_ENABLED:
      en: "Enabled"
      zh: "启用"

    LBL_PARAMETER_NAME:
      en: "Parameter Name"
      zh: "参数名称"

    LBL_ISMODIFIABLE:
      en: "Is Modifiable"
      zh: "可修改"

    LBL_APPLY_METHOD:
      en: "Apply Method"
      zh: "应用类型"

    LBL_SOURCE:
      en: "Source"
      zh: "源"

    LBL_ORIGINAL_VALUE:
      en: "Original Value"
      zh: "原始值"

    LBL_EDIT_VALUE:
      en: "Edit Value"
      zh: "编辑值"

    LBL_PARAMETER_VALUE_REFERENCE:
      en: "Parameter Value Reference"
      zh: "参数值"

    LBL_BACK_TO_EDITING:
      en: "Back to Editing"
      zh: "返回编辑"

    LBL_APPLY_CHANGES:
      en: "Apply Changes"
      zh: "应用更改"

    LBL_REVIEW_CHANGES_SAVE:
      en: "Review Changes & Save"
      zh: "检查更改并保存"

    LBL_APPLYING:
      en: "Applying..."
      zh: "应用中..."

    LBL_CREATE_SUBSCRIPTION:
      en: "Create Subscription"
      zh: "创建订阅"

    LBL_TOPIC:
      en: "Topic"
      zh: "主题"

    LBL_TOPIC_ARN:
      en: "Topic ARN"
      zh: "主题 ARN"

    LBL_SUBSCRIPTION:
      en: "Subscription"
      zh: "订阅"

    LBL_UPLOAD_NEW_SSL_CERTIFICATE:
      en: "Upload New SSL Certificate"
      zh: "上传新服务器证书"

    LBL_UPLOAD_DATE:
      en: "Upload Date"
      zh: "上传时间"

    LBL_VIEW_DETAILS:
      en: "View Details"
      zh: "查看详情"

    LBL_CREATE_DHCP_OPTIONS_SET:
      en: "Create DHCP Options Set"
      zh: "创建 DHCP 选项组"

    LBL_OPTIONS:
      en: "Options"
      zh: "选项"

    LBL_CREATE_PARAMETER_GROUP:
      en: "Create Parameter Group"
      zh: "创建参数组"

    LBL_EDIT:
      en: " Edit "
      zh: "编辑"

    DELETE_SNAPSHOT_1:
      en: "Confirm to delete "
      zh: "确认删除 "

    DELETE_SNAPSHOT_2:
      en: "selected "
      zh: "选择的 "

    DELETE_SNAPSHOT_3:
      en: " Snapshot(s) "
      zh: " 快照"




    OPTION_SETTING:
      en: "Option Setting"
      zh: "选项设置"

    VALUE:
      en: "Value"
      zh: "值"

    ALLOWED_VALUES:
      en: "Allowed Values"
      zh: "允许的值"

    OPTION_GROUP_DESCRIPTION:
      en: "Option Group Description"
      zh: "选项组描述"

    ENGINE_VERSION:
      en: "Engine Version"
      zh: "引擎版本"

    PERSISTENT:
      en: "PERSISTENT"
      zh: "持续的"

    PERMENANT:
      en: "PERMANENT"
      zh: "永久的"

    OPTION:
      en: "Option"
      zh: "选项"

    HIDE_DETAILS:
      en: "Hide details"
      zh: "隐藏详情"

    PORT_COLON:
      en: "Port:"
      zh: "端口:"

    SECURITY_GROUP_COLON:
      en: "Security Group:"
      zh: "安全组:"

    SETTING:
      en: "Setting"
      zh: "设置"

    NO_OPTION_GROUP_PERIOD:
      en: "No Option Group."
      zh: "无选项组"

    CREATE_OPTION_GROUP:
      en: "Create Option Group"
      zh: "创建选项组"

    SHOW_DETAILS:
      en: "Show details"
      zh: "显示详情"

    SECURITY_GROUP:
      en: "Security Group"
      zh: "安全组"

    SAVE_OPTION:
      en: "Save Option"
      zh: "保存选项"

    NAME:
      en: "Name"
      zh: "名称"

    SAVE:
      en: "Save"
      zh: "保存"

    DESCRIPTION:
      en: "Description"
      zh: "描述"

    CONFIRM_TO_DELETE_THIS_OPTION_GROUP_QUESTION:
      en: "Confirm to delete this option group?"
      zh: "确认要删除此选项组?"

    STATIC_SUB_CHANGE_AMI:
      en: "Change AMI"
      zh: "更换 AMI"

    DRAG_IMAGE_DROP_TO_CHANGE:
      en: "Drag image from Resource Panel and drop below to change AMI."
      zh: "从资源面板拖拽镜像放到下面以更换 AMI"

    DRAG_IMAGE_DROP_HERE:
      en: "Drop AMI Here"
      zh: "将 AMI 拖到这里"

    CONFIRM_CHANGE_AMI:
      en: "Confirm Change AMI"
      zh: "确认更换 AMI"

    ROLLING_BACK:
      en: "Rolling back..."
      zh: "回滚中..."

    ALLOW:
      en: "Allow"
      zh: "允许"

    INITIATE_TRAFFIC_TO:
      en: "initiate traffic to"
      zh: "允许流量到"

    ACCEPT_TRAFFIC_FROM:
      en: "accept traffic from"
      zh: "接受流量从"

    HAVE_2WAY_TRAFFIC_WITH:
      en: "have 2-way traffic with"
      zh: "互通流量与"

    DESTINATION_PROTOCOL:
      en: "Destination Protocol"
      zh: "目的协议"

    PORT_RANGE_COLON:
      en: "Port Range: "
      zh: "端口范围: "

    ADD_RULE:
      en: "Add Rule"
      zh: "添加规则"

    RULE_REF_ITS_OWN_SG:
      en: "You have created a rule referencing its own security group. This rule will not be visualized as the blue connection lines."
      zh: "你已经创建了一个引用安全组自己的规则．这条规则将不会体现在蓝色的连接线上"

    CREATE_ANOTHER_RULE:
      en: "Create another rule"
      zh: "创建其他规则"

    RELATED_RULE:
      en: "Related Rule"
      zh: "相关的规则"

    CREATE_SECURITY_GROUP_RULE:
      en: "Create Security Group Rule"
      zh: "创建安全组规则"

    NONE:
      en: "None"
      zh: "无"

    SUBSCRIPTIONS:
      en: "Subscriptions"
      zh: "订阅"

    SELECT_TOPIC:
      en: "Select Topic"
      zh: "选择主题"

    NEW_TOPIC:
      en: "New Topic"
      zh: "创建主题"

    TOPIC_NAME:
      en: "Topic Name"
      zh: "主题名称"

    DISPLAY_NAME:
      en: "Display Name"
      zh: "显示名称"

    CREATING_3PERIOD:
      en: "Creating..."
      zh: "创建中..."

    DELETING_3PERIOD:
      en: "Deleting..."
      zh: "删除中..."

    SUBSCRIPTION_ARN:
      en: "Subscription ARN"
      zh: "订阅 ARN"

    CREATE_SNS_TOPIC:
      en: "Create SNS Topic"
      zh: "创建 SNS 主题"

    SNS_TOPIC:
      en: "SNS Topic"
      zh: "SNS 主题"

    NO_SNS_TOPIC_IN_XXX:
      en: "No SNS Topic in %s."
      zh: "%s 中尚无 SNS 主题"

    UPLOAD:
      en: "Upload"
      zh: "上传"

    UPLOAD_3PERIOD:
      en: "Upload..."
      zh: "上传中..."

    UPDATE:
      en: "Update"
      zh: "更新"

    UPDATING_3PERIOD:
      en: "Updating..."
      zh: "更新中..."

    SERVER_CERTIFICATE_ID:
      en: "Server Certificate ID"
      zh: "服务器证书 ID"

    SERVER_CERTIFICATE_ARN:
      en: "Server Certificate ARN"
      zh: "服务器证书 ARN"

    EXPIRATION_DATE:
      en: "Expiration Date"
      zh: "过期日期"

    PATH:
      en: "Path"
      zh: "路径"

    NO_SSL_CERTIFICATE:
      en: "No SSL Certificate."
      zh: "无 SSL 证书"

    CREATE_SSL_CERTIFICATE:
      en: "Create SSL Certificate"
      zh: "创建 SSL 证书"

    NO_FAILED_ITEM_PERIOD:
      en: "No failed item."
      zh: "无失败的项"

    ALL_STATES_ARE_PENDING_PERIOLD:
      en: "All states are pending."
      zh: "所有 state 都在等待中"

    A_MESSAGE_WILL_SHOW_HERE:
      en: "A message will show here when a state succeeds or fails."
      zh: "当 state 成功或失败时消息将显示在这里"

    XXX_STATES_HAS_UPDATED_STATUS:
      en: "%s states has updated status."
      zh: "%s 条 state 有状态更新"

    FAILED_STATE:
      en: "Failed State"
      zh: "失败的 state"

    EXPAND:
      en: "Expand"
      zh: "展开"

    EG_MINUS_1:
      en: "eg. -1"
      zh: "例如： -1"

    EG_5:
      en: "eg. 5"
      zh: "例如：5"

    EG_MINUS_30:
      en: "eg. -30"
      zh: "例如：-30"

    REMOVE_ROUTE:
      en: "Remove Route"
      zh: "删除路由"

    REMOVE_SUBNET:
      en: "Remove Subnet"
      zh: "删除子网"

    RESOURCE_NAME_KEYPAIR:
      en: "keypair"
      zh: "密钥对"

    RESOURCE_NAME_EIP:
      en: "Elastic IP"
      zh: "弹性 IP"

    RESOURCE_NAME_PARAMETER_GROUP:
      en: "RDS Parameter Group"
      zh: "数据库参数组"

    RESOURCE_NAME_RDS_SNAPSHOT:
      en: "RDS Snapshot"
      zh: "数据库快照"

    RESOURCE_NAME_SNAPSHOT:
      en: "Snapshot"
      zh: "快照"

    RESOURCE_NAME_SNS:
      en: "SNS Subscription"
      zh: " SNS 订阅"

    RESOURCE_NAME_SSL:
      en: "SSL"
      zh: "SSL"

    RESOURCE_NAME_DHCP:
      en: "DHCP"
      zh: "DHCP"

    RESOURCE_NAME_OPTION_GROUP:
      en: "RDS Option Group"
      zh: " RDS 选项组"

    LC_WILL_BE_REPLECED:
      en: "Launch Configuration will be replaced for all associated AutoScaling Group, and AutoScaling Group will scale base on the policy."
      zh: "关联的AutoScaling组的启动配置都将被替换，并且AutoScaling组会根据设置的策略自动扩展。"




