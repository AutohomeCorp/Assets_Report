## Assets Report Plugin

本插件的作用是通过Puppet的Facter机制自动采集服务器的配置数据。

**原理简介**

本插件包含了自定义facts，每次Agent运行时都会利用这些代码采集数据，然后汇报给Puppet Master，Puppet
 Master会利用本插件提供的自定义Report Processor通过HTTP协议将数据汇报给CMDB。CMDB只需要编写相应的HTTP接口负责将数据入库即可。

## 特性

相对于Facter内建的facts，本插件提供了更多的硬件数据，例如

1. CPU个数，型号
2. 内存容量，序列号，厂商，插槽位置
3. 网卡上绑定的ip，掩码，mac，型号，且支持一个网卡上绑定多ip的场景
4. RAID卡个数，型号，内存容量，RAID Level
5. 磁盘个数，容量，序列号，厂商，所属RAID卡，插槽位置
6. 操作系统类型，版本
7. 服务器厂商，SN

高级特性：为了避免大段相同数据重复上报，减轻CMDB的数据库压力，本插件具备Cache功能。即如果一台服务器的资产数据没有发生变更，那么只会汇报`not_modify`标记。

本插件支持的操作系统有(系统必须是64位的，因为本插件中的采集工具是64位的)

1. CentOS-6
2. CentOS-7
3. Windows 2008 R2

本插件支持的服务器有

1. HP
2. DELL
3. CISCO

## 依赖

因为本插件使用了Facter机制，所以依赖

1. Ruby
2. Puppet
3. Facter

其他工具均自包含在插件里，没有外部依赖

## 安装

将整个代码目录放到Puppet Master的模块目录，假定你的模块目录为`/etc/puppet/modules`

    cd /etc/puppet/modules
    git clone git@github.com:AutohomeOps/Assets_Report.git assets_report

然后让所有Node都`include assets_report`模块，通过模块中`manifests/init.pp`的配置，采集工具会被自动下发到服务器上进行安装。下一次Puppet Agent运行时本插件即可正常工作。

## 配置

配置文件为 **lib/puppet/reports/report_setting.yaml**

| 参数            | 含义          | 示例                                  |
| ------------- | ----------- | ----------------------------------- |
| report_url    | 汇报接口地址      | http://localhost/api/report         |
| auth_required | 接口是否包含验证    | true/false，默认为false，验证代码在auth.rb中实现 |
| user          | 验证用户名       | 如果auth_required为true，需要填写           |
| passwd        | 验证密码        | 如果auth_required为true，需要填写           |
| enable_cache  | 是否启用cache功能 | true/false, 默认为false                |

## 使用

手动触发

```
puppet agent -t
```
或者 puppet agent的daemon自动运行时，CMDB接口将会接到一次HTTP调用。

## 数据格式

    {
      'os_type' # 操作系统类型
      'os_distribution' # 操作系统发行版本
      'os_release' # 操作系统版本号
      'not_modify' # 本次数据跟上次比是否有变更
      'setuptime' # 系统安装时间
      'sn' # 序列号
      'manufactory' # 服务器制造商
      'productname' # 服务器产品名称 
      'model' # 服务器型号
      'cpu_count' # 物理CPU个数
      'cpu_core_count' # CPU逻辑核数
      'cpu_model' # CPU型号
      'nic_count' # 网卡个数
      'nic' # 网卡的详细参数
      'raid_adaptor_count' # raid卡控制器个数
      'raid_adaptor' # raid卡控制器详细参数
      'raid_type' # raid类型
      'physical_disk_driver' # 物理磁盘详细参数
      'ram_size' # 内存总容量
      'ram_slot' # 内存详细参数
      'certname' # Puppet的certname
    }
## 开发和贡献

我们非常欢迎大家参与到开发中来，欢迎提交issue，尤其是Pull Request。

## 支持和社区

### QQ群

您可以加入我们的官方开源QQ群452994151进行交流。

### Mail

您可以通过autohomeops@autohome.com.cn与我们联系。

### Bug提交

如果您发现任何错误或者有任何建议，请在这里提交
<https://github.com/AutohomeRadar/Assets-Report/issues>

### Wiki
<https://github.com/AutohomeRadar/Assets-Report/wiki>

### 博客

团队官方博客 <http://autohomeops.corpautohome.com>

### License

本软件遵守Apache许可证授权。有关完整的许可证文本，请参阅顶根目录中的LICENSE文件。
