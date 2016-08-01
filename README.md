# FlexInjected

# iOS 越狱的Tweak开发

> iOS越狱开发中，各种破解补丁的统称为Tweak,通常意义上我们说的越狱开发,都是指开发一个Tweak.
基本上,tweak都依赖于一个名叫[cydia Substrate](http://www.cydiasubstrate.com) (以前名字也叫mobile Substrate)的动态库,Mobile Substrate是Cydia的作者Jay Freeman (@saurik)的作品，也叫Cydia Substrate,它的主要功能是hook某个App，修改代码比如替换其中方法的实现，Cydia上的tweak都是基于Mobile Substrate实现的.

> iOS的tweak开发可以有两种发布方式   
  1.  只能在越狱设备上安装的打包成deb格式的安装包  
  2.  直接使用开发者自己的证书/企业证书直接将补丁打包成ipa,这样不需要越狱也是可以安装的,只是这种非越狱的限制比较大,通常只是用来给某个app打个补丁或者类似的功能啥的





## tweak是啥?
tweak的实质就是ios平台的**动态库**。IOS平台上有两种形势的动态库，dylib与framework。Framework这种开发者用的比较多，而dylib这种就相对比较少一点，比如libsqlite.dylib，libz.dylib等。而tweak用的正是dylib这种形势的动态库。我们可以在设备的**/Library/MobileSubstrate/DynamicLibraries**目录下查看手机上存在着的所有tweak。这个目录下除dylib外还存在着plist与bundle两种格式的文件，plist文件是用来标识该tweak的作用范围，而bundle是tweak所用到的资源文件



## 开发tweak最常用的theos环境安装

TheOS被设计为一个在基于Unix平台开发IOS程序的集成开发环境,它给我们准备好了一些代码模板、预置一些基本的Makefile脚本，这样我们开发一个tweak就会变得方便的多,这里我们不说简单的多,是因为其配置还是稍显繁琐的,并且,也不能像我们通常开发xcode工程那样方便的调试.
  
theos的开发者是大神[DHowett]( https://github.com/DHowett/theos),不过大从2015年开始,原作者不再更新,交给社区维护了,新的地址是https://github.com/theos/theos.

网上的多数教程都是基于原作者两年前的原始theos来配置环境的,原始的配置环境的方式相对来说比较繁琐.
这里,我们介绍最新的theos环境配置

最新环境的地址是 https://github.com/theos/theos
其实只要将git地址的内容下载下来,然后放到一个目录下就可以了,网上的教程都是放到/opt/theos

1.是将theos环境下载下来,theos是放在github上的,使用git命令来clone比较方便,虽然可以放在任何目录下,但是官方建议大家放在 /opt/下
打开 终端
输入  export THEOS=/opt/theos  #这个是建立一个环境变量方便后面的操作(引用这个环境变量是用$THEOS)
> 这种建立环境变量的方式,只是在当前终端中起作用了,关闭终端后又得重新设置,为了避免每次都建立这个环境变量,我们可以建立一个永久的环境变量  
>  编辑~/.profile文件,在其中添加export THEOS=/opt/theos/,这个环境变量就是永久的了.
> ps:怎么查看定义了哪些环境变量呢?  终端中输入命令env!

```
git clone --recursive https://github.com/theos/theos.git $THEOS
```
这个目录和终端变量$THEOS只是方便我们操作,其实你也可以放在任何你想放置的目录.
新版的theos下载下来后,其内部已经内置了cydia framework和iOS的一系列私有的头文件等,不需要像以前版本那样,自己从手机上或者其它地方拷贝cydia的lib来了,其放置的目录是vendor/lib和vendor/include  
  
![](http://7xqspl.com1.z0.glb.clouddn.com/image/c/c6/baad688e0cc75974df400fffbf6e3.png)
  ,新版的已经是内置CydiaSubstrate.framework,不是网上其它教程中说的需要运行bootstrap.sh脚本或者是从手机上拷贝等方式.  
**备注:最新版的已经没有这个bootstrap.sh脚本文件了.2016.08.15,并且已经集成了最新的cydia Substrate,在目录Vendor/lib下
这里的cydia使用的是framework模式了
看到官方的git中有注释  
   [common] Move vendored includes and libraries to a vendor/ subdir.**  
>> 旧版的中
>> ~~首先运行Theos的自动化配置脚本:~~ 
>> ~~ sudo /opt/theos/bin/bootstrap.sh substrate ~~
>> ~~由于Theos存在一个bug，所以无法自动生成一个有效的libsubstrate.dylib文件，需要手动添加，需>> 要再Cydia中搜索安装CydiaSubstrate，并且拷贝到电脑中，重命名为libsubstrate.dylib后放 到/opt/theos/lib/中~~



2.配置用来签名的ldid,如果不安装,那么产生的deb文件就安装不到手机上,
用来专门签名iOS可执行文件的工具,用以在越狱iOS中取代Xcode自带的codesign.  
安装这个ldid,推荐的方式是采用brew来安装-- **brew install ldid**

>> 
~~从http://joedj.net/ldid下载ldid,放到/opt/theos/bin/下,然后用命令chmod 777 /opt/theos/bin/ldid 来提升它的权限~~
~~看到另一篇文章(http://www.kanxue.com/bbs/showthread.php?p=1303343)说的可以在 git clone git://git.saurik.com/ldid.git 下载编译ldid~~
~~完成以上操作会在ldid目录下生产一个mac 可执行程序 ldid~~



3.配置dpkg-deb
新版的theos,其没有内置 dpkg-deb,需要你用brew来安装dpkg  (brew install dpkg)
> brew查看安装了哪些工具的命令是 brew list

如果你没安装,那么可能会收到如下警告

```sh
SZ-lingdaiping:FLEXLoader-master yohunl$ make package
==> Error: /Applications/Xcode.app/Contents/Developer/usr/bin/make package requires dpkg-deb.
make: *** [internal-package-check] Error 1
```

deb是越狱开发包的标准格式,dpkg-deb是个用于操作deb文件的工具,有了这个工具,Theos才能正确的把工程打包成deb文件,~~旧版的
从https://github.com/DHowett/dm.pl 下载dm.pl文件(**其实新版的theos的bin目录下包含了这个文件了**),将其重命名为dpkg-deb后,放到/opt/theos/bin/目录下,chmod 777 /opt/theos/bin/dpkg-deb 来提升它的权限,再拷贝到theos/bin下了!!~~

4.配置Theos NIC templates (可选)

**目前最新版的已经内置了所有模板了**
![711D1D8D18BF3677313D077F87790CEC.png](http://7xqspl.com1.z0.glb.clouddn.com/image/7/11/d1d8d18bf3677313d077f87790cec.png)



## tweak的demo简介
下面我们来创建一个默认的demo来简单说明一下
打开一个终端,

```sh
$THEOS/bin/nic.pl
```

可以看到

```sh
NIC 2.0 - New Instance Creator
------------------------------
  [1.] iphone/activator_event
  [2.] iphone/application_modern
  [3.] iphone/cydget
  [4.] iphone/flipswitch_switch
  [5.] iphone/framework
  [6.] iphone/ios7_notification_center_widget
  [7.] iphone/library
  [8.] iphone/notification_center_widget
  [9.] iphone/preference_bundle_modern
  [10.] iphone/tool
  [11.] iphone/tweak
  [12.] iphone/xpc_service
Choose a Template (required):
```

通常我们建立的都是tweak,所以选11(可能你的不是11)

接下来,输入工程的名称

```sh
Project Name (required): yohunlTemp
```

再下来是输入package的名字,这里可以回车,采用默认值,这里的默认是是com.yourcompany.project Name

```sh
Package Name [com.yourcompany.flextemp]:
```

再下来是输入作者名,默认值是你的电脑的用户名

```sh
Author/Maintainer Name [yohunl]: 
```

再下来,是输入tweak可以作用的对象的bundle identifier

```sh
[iphone/tweak] MobileSubstrate Bundle filter [com.apple.springboard]: 
```

这里要说明一下了,这里的com.apple.springboard是iOS的桌面app,如果我们的tweak是想作用于所有的app呢?那么这里应该填 com.apple.UIKit,这一步填入的内容是对应于建立后的一个名字为  工程名.plist的配置文件,这个文件的内容大概如以下这样

```
{ Filter = { Bundles = ( "com.apple.springboard" ); }; }
```

当然了,这里可以更进一步的控制,具体可以去网上搜索

接下来,是输入安装完成后,需要重启的应用

```sh
[iphone/tweak] List of applications to terminate upon installation (space-separated, '-' for none) [SpringBoard]:
```

建立后的工程目录如下
![](http://7xqspl.com1.z0.glb.clouddn.com/image/2/cb/a93f9d789da388ddeaa0b21d35981.png)

共有4个文件,其中
control文件中

```
Package: com.yourcompany.flextemp
Name: flexTemp
Depends: mobilesubstrate
Version: 0.0.1
Architecture: iphoneos-arm
Description: An awesome MobileSubstrate tweak!
Maintainer: yohunl
Author: yohunl
Section: Tweaks
```

是工程的一些常用的配置

flexTemp.plist文件,就是我们建立工程中输入的[iphone/tweak] MobileSubstrate Bundle filter

```
{ Filter = { Bundles = ( "com.apple.springboard" ); }; }
```

makefile文件

```
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = flexTemp
flexTemp_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
```

这里有$(THEOS),这个变量,这也是我们上面用export建立的,如果你没建立,新版的你要自己修改这里了

```
include $(THEOS)/makefiles/common.mk
```

这个都要添加的,因为很多关键的变量等,都在common.mk中,不包含这个,很多东西都用不了.例如编译过程中很多的变量的定义都在其中
```
THEOS_MAKE_PATH := $(THEOS)/makefiles
THEOS_BIN_PATH := $(THEOS)/bin
THEOS_LIBRARY_PATH := $(THEOS)/lib
THEOS_INCLUDE_PATH := $(THEOS)/include
THEOS_MODULE_PATH := $(THEOS)/mod
```
flexTemp_FILES = Tweak.xm 是我们要包含的需要被编译的文件,格式就是 工程名_FILES = 要编译的文件名

Tweak.xm文件

```objective-c
%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/
```

这个文件中,就是我们tweak的核心代码,其中的%hook,%orig,%log等都是theos对cydia Substrate提供的函数的宏封装,cydia Substrate提供的方法的介绍可以参考[Cydia_Substrate]( http://iphonedevwiki.net/index.php/Cydia_Substrate)
cydia Substrate提供了三方最重要的方法
``` objc
 IMP MSHookMessage(Class class, SEL selector, IMP replacement, const char* prefix); > // prefix should be NULL.
 void MSHookMessageEx(Class class, SEL selector, IMP replacement, IMP *result);
 void MSHookFunction(void* function, void* replacement, void** p_original);
```
 这三个都是用来进行hook操作的,也就是我们在非越狱开发中常说的swizzle!
 cydia Substrate还提供了MobileLoader：“钩子”需要在运行时被加载，靠的就是MobileLoader的功劳。MobileLoader会在适当的时机加载/Library/MobileSubstrate/DynamicLibraries/目录下的动态库（.dylib，这是tweak的最终产品）


 MobileLoader能够在运行时候加载dylib的核心是利用
** __attribute__((constructor))的方法会在main函数执行之前执行!!!!!!**
``` objc
...
// The attribute forces this function to be called on load.
__attribute__((constructor))
static void initialize() {
  NSLog(@"MyExt: Loaded");
  MSHookFunction(CFShow, replaced_CFShow, &original_CFShow);
}
```


Tweak.xm的文件名后缀x代表这个文件支持Logos语法，如果只有一个x代表源文件支持Logos和C语法；如果是xm，说明源文件支持Logos和C/C++语法。其中的%hook,%orig,%log等都是Logos语法支持的内容,详细语法说明请参考http://iphonedevwiki.net/index.php/Logos (不要被这个语法吓着了,Logos作为Theos开发组件的一部分，通过一组特殊的预处理指令，可以让编写函数钩子（hook）代码变得非常简单和清晰,Logos是随着Theos发布的，你能够在用Theos创建的项目中直接使用Logos的语法,如果不是Theos创建的工程,则使用不了哦)


到此为止,我们的demo已经建立起来了

如何编译和安装呢?
命令 make package就是编译deb安装包的
执行后,目录下会多出来几个文件和文件夹
![2016-08-01_10-25-53.jpg](http://7xqspl.com1.z0.glb.clouddn.com/image/6/25/6ab11644716d65901d78b1091b968.jpg)
其中packages文件夹下保留的是每一次编译成功产生的deb安装包文件

还有个隐藏的目录 .theos
其内容如下
![2016-08-01_10-50-29.jpg](http://7xqspl.com1.z0.glb.clouddn.com/image/e/61/651e578343f3eb0c8c82d8dd92047.jpg)
其中的_文件夹下面
DEBIAN文件夹下面是deb安装到手机上后的控制文件信息,这个文件就是我们建立工程时候生成的那个control文件
其他的目录和文件都是安装后对应到手机上的真实文件,在这里显示出来,是为了方便用开发者查看,安装后在手机系统中哪些目录生成了哪些文件

## 怎么安装deb包和卸载deb包?
上面我们生成了能够用于安装到手机上的deb安装包了,怎么安装到手机上呢?

大体上可以有两种方法

方法一:  
图形方式,使用iTools等工具将这个deb包拷贝到手机中,利用iFile浏览到此文件,进行安装

方法二:   
需要使用到openssh服务,确保你手机上已经安装了该服务(cydia中搜索安装)
> 要安装 OpenSSH 首先需要将设备越狱。越狱完成之后,就可以在 Cydia 中直接查找和安装 OpenSSH。安装完成之后就可以通过下面的步骤来将你的 Mac 连接到 iOS 设备。

> - 首先得保证你的 iOS 设备和 Mac 在同一局域网的同一网段中。
> - 打开终端，输入 ssh root@192.168.xxx.xxx
> - 输入 iOS 设备密码，默认 alpine(强烈建议修改此默认密码,否则任何人都可以通过ssh连接到你手机上,然后获取你的信息)
> - 等待连接，稍后，您就连接到您的iPhone、iPad上，可以执行 Unix 命令了。
> - 还可以使用 Transmit 等软件来管理 iOS 设备的文件系统，非常方便。

在编译用的makefile文件最上面
添加
THEOS_DEVICE_IP = 你的手机的IP地址

然后使用 make package install命令,可以一次性完成编译,打包,安装一条龙服务,这个过程中可能需要要你两次输入ssh的root密码((一次是签名打包,一次是安装)).

这样还是稍显繁琐,每一次修改后,编译运行,都得输入两此手机的root密码,如果你连这两次都懒得输入,也是有办法的


brew安装openssh(brew install openssl)和 ssh-copy-id(brew install ssh-copy-id)
执行命令
```
ssh-keygen -t rsa -b 2048
```
按提示输入存放keygen存放的目录(最好是自己输入存放的目录的文件,而不是采用默认的,以防万一覆盖了其它的ssh)
再执行命令
```
ssh-copy-id root@<iP Address of your device>
```
然后,就可以不用密码安装了! 节约了两次密码的输入(一次是签名打包,一次是安装)

说完了安装,那么我们怎么卸载一个安装的deb包呢?
方式一:   cydia可删除它,安装的deb包都在cydia的已安装列表中有显示
![IMG_4714.PNG](http://7xqspl.com1.z0.glb.clouddn.com/image/b/a9/63006780cbc51a160a0327de4cf66.png)

方式二  
如果手机上安装了dpkg(越狱手机上,一般都是安装了的,名字叫 Debian Package),那么将一个deb文件拷贝到手机里,就可以在手机中的终端(可以cydia安装MTerminal,MTerminal是一款越狱手机上的命令行终端环境)中执行dpkg -i com.daapps.FLEXInjected_0.0.1-1-7_iphoneos-arm.deb 来安装一个deb,(当然你也可以使用cydia来自动安装,或者pp助手等,也可以),安装完要重启springboard,使用命令  killall -HUP SpringBoard
卸载一个软件  dpkg -r com.daapps.FLEXInjected
> **例如   dpkg -r com.yourcompany.testmywtweak **  
(我们在theos环境打包出来的deb名字可能是com.yourcompany.testmywtweak_0.0.1-1_iphoneos-arm.deb等,但是最后在系统里的tweak的名字是com.yourcompany.testmywtweak )!


顺便提一句
若是只是想修改其它的deb包的某个文件,该怎么弄呢?
deb包的解读
,其实它就是一个压缩文件而已…你可以使用rar等解压缩工具解压缩,但是这样会丢失原有的文件的权限信息!
一个 deb 安装包由两部分组成，一个是安装控制/识别信息，另外一个就是实际的程序文件。


需要修改现有的deb包，那么第一步就是解包。

假设deb的文件名是abc.deb，解包命令为：

dpkg-deb -x abc.deb tmp     #将abc.deb的程序文件解包到tmp文件夹

dpkg-deb -e abc.deb tmp/DEBIAN     #将abc.deb的安装控制/识别信息解包到DEBIAN文件夹

**注：安装控制/识别信息必须在当前程序文件文件夹中的DEBIAN文件夹中，必须大写。**

进入DEBIAN目录，可以看到有一个control文件，无后缀名，这个文件就是用来记录deb的安装信息。

另外，postinst，preinst，prerm，postrm，extrainst_这些脚本文件，不是必须存在的，当安装包需要使用到脚本的时候才会用到的。脚本在后面的章节会详细讲到的，这一节我们先不管。

接下来介绍的是打包命令：

假设将需要打包的文件放在tmp文件夹中，DEBIAN文件夹也要在放在这个文件夹中，然后输入命令：

chmod -R 0755 tmp/DEBIAN     #首先设置权限，如果没有包含脚本可以不需要设置权限

dpkg-deb -b tmp 1.deb     #打包成一个叫做1.deb的包

如此这般,就完成了修改某个已存在的deb包了


OK,目前为止,我们已经介绍完了基础知识

下面让我们用一个稍微复杂一些的例子来演示一下 如何让Flex可以嵌入到所有的APP中


## flex的动态嵌入

### flex的简介
https://github.com/Flipboard/FLEX, FLEX是Flipboard开源的一款方便的应用内调试工具，开发者可在toolbar中查看和修改运行中的应用.  
它提供了功能：
* 可以在层级中检测和调整视图，可查看每个对象上的属性和变量；
* 动态调整任何属性和变量；
* 动态调用实例和类方法；
* 通过扫描 heap访问任何活跃的对象；
* 在app的sandbox中查看文件系统；
* 探究应用中所有类和系统框架（公开的和私有的）；
* 快速访问有用的对象（比如[UIApplication sharedApplication]）、app委托以及关键窗口的根视图控制器等；
* 动态查看和调整 NSUserDefaults 值
* 显示所有的NSLog信息
* 显示所有的网络包等等

它是一个开源的框架集合,在我们自己的工程中,当然可以添加源码就可以用起来了,那么如果我们能够在其他的app中也嵌入它,那我们岂不是可以直接学习到其他app的UI布局等等,想想是不是就很激动呢?
官网截图
![687474703a2f2f656e67696e656572696e672e666c6970626f6172642e636f6d2f6173736574732f666c65782f666c65782d726561646d652d726576657273652d312e706e67.png](http://7xqspl.com1.z0.glb.clouddn.com/image/e/51/f91b046ada73e42a8160d6c003163.png)

看到没,可以用来分析系统的电话界面

额.....但是.....官网并没有告诉我们怎么做到这点,说是留给我们自己一个小练习....呵呵,这个练习可不小呀..

### 动态嵌入flex

首先,我们应该有一个可以选取所有的app的列表,通过这个列表,我们可以决定哪个应用可以嵌入flex.可喜的是,这个工作已经有人替我们完成了

[APPlist]( https://github.com/rpetrich/AppList) 是个辅助获取已安装程序列表的插件，利用PreferenceLoader在设置中增加一个App列表，并可以供用户设置

preferenceloader是手机越狱必备的软件，如果少了preferenceloader，你的iphone.ipad.越狱后很多插件都会无法使用。preferenceloader是很多插件的依赖，例如非常出名的Activator需要它才能正常工作
https://github.com/DHowett/preferenceloader

说的再简单一点,就是我们可以利用preferenceloader和applist,很方便的在系统给的设置那里提供一个可以选择app的列表
![IMG_4715.PNG](http://7xqspl.com1.z0.glb.clouddn.com/image/e/17/eb28070d0097e049e3d4842870152.png)


需要在设备的/Library/PreferenceLoader/Preferences下放置一个指定格式的plist文件和两个图标文件(图标文件是为了在系统的设置中显示)

怎么这个文件放在theos工程的哪里,最后安装后,才能在设备的/Library/PreferenceLoader/Preferences目录下呢?
Theos已经帮我们想到这点了,在Theos建立的工程的根目录下建立一个 layout文件夹,这个文件夹就相当于设备的根目录了!在编译生成的deb包中,会自动放到对应的文件夹

在工程的目录下创建 layout文件夹  这里的**layout相当于iOS的文件系统的根目录**
![2016-08-01_13-16-15.jpg](http://7xqspl.com1.z0.glb.clouddn.com/image/6/60/8a59fd18b2f9dc2e99479d65f3a4f.jpg)

在其中放入一个控制系统设置项的plist文件FLEXInjected.plist
```
entry = {
  bundle = AppList;
  cell = PSLinkCell;
  icon = "/Library/PreferenceLoader/Preferences/FLEXInjected.png";
  isController = 1;
  label = FLEXInjected;
  ALSettingsPath = "/var/mobile/Library/Preferences/com.yourcompany.flexinjected.plist";
  ALSettingsKeyPrefix = "FLEXInjectedEnabled-";
  ALChangeNotification = "com.yourcompany.flexinjected.settingschanged";
  ALSettingsDefaultValue = 0;
  ALSectionDescriptors = (
  	
  	{
  	  title = "User Applications";
  	  predicate = "(isSystemApplication = FALSE)";
  	  "cell-class-name" = "ALSwitchCell";
  	  "icon-size" = 29;
  	  "suppress-hidden-apps" = 1;
  	  
  	},
  	{
  	  title = "System Applications";
  	  predicate = "(isSystemApplication = TRUE)";
  	  "cell-class-name" = "ALSwitchCell";
  	  "icon-size" = 29;
  	  "suppress-hidden-apps" = 1;
  	  "footer-title" = "© yohunl create for demo";
  	}
  );
};
```


下载Flex的工程,编译产生FLEX.framework这个动态库,将其放入
![2016-08-01_13-32-02.jpg](http://7xqspl.com1.z0.glb.clouddn.com/image/9/c0/6b9dba7d406ee90b69a7a4999f118.jpg)

打开Tweak.xm文件
添加如下代码
``` objc
/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.
*/
#include <dlfcn.h>


@interface MyDKFLEXLoader : NSObject

@end

@implementation MyDKFLEXLoader

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MyDKFLEXLoader *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)show
{
	// [[FLEXManager sharedManager] showExplorer];

	Class FLEXManager = NSClassFromString(@"FLEXManager");
	id sharedManager = [FLEXManager performSelector:@selector(sharedManager)];
	[sharedManager performSelector:@selector(showExplorer)];
}

@end



%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourcompany.flexinjected.plist"] ;
        NSString *libraryPath = @"/Library/Application Support/FLEXLoader/FLEX.framework/FLEX";
        
        NSString *keyPath = [NSString stringWithFormat:@"FLEXInjectedEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]];
        NSLog(@"SSFLEXLoader before loaded %@,keyPath = %@,prefs = %@", libraryPath,keyPath,prefs);
        if ([[prefs objectForKey:keyPath] boolValue]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath]){
                void *haldel = dlopen([libraryPath UTF8String], RTLD_NOW);
            if (haldel == NULL) {
                char *error = dlerror();
                NSLog(@"dlopen error: %s", error);
            } else {
                NSLog(@"dlopen load framework success.");
                [[NSNotificationCenter defaultCenter] addObserver:[MyDKFLEXLoader sharedInstance] 
											selector:@selector(show) 
											name:UIApplicationDidBecomeActiveNotification 
											object:nil];
                    
                
            }

            NSLog(@"SSFLEXLoader loaded %@", libraryPath);
            } else {
                NSLog(@"SSFLEXLoader file not exists %@", libraryPath);
            }
        }
        else {
            NSLog(@"SSFLEXLoader not enabled %@", libraryPath);
        }
        
        NSLog(@"SSFLEXLoader after loaded %@", libraryPath);


    [pool drain];
}



```

简单的代码说明
NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourcompany.flexinjected.plist"] .这个文件是我们在上面的plist中定义的用来存放用户选择的app列表的.通过读取它我们就可以知道用户选中了哪个app.

然后使用dlopen动态的打开framework,注入到响应的app进程中去

详细的代码我已经放到github上去了,地址是  https://github.com/yohunl/FlexInjected


编译的命令是 make
打包成deb安装包的命令是 make package
编译,打包,安装一条龙的命令是 make package isntall,当然了,你需要先修改Makefile文件中的THEOS_DEVICE_IP = 10.0.44.136 为你自己越狱设备的ip地址

稍后,你的越狱设备将会重启,然后,就可以在设置那里看到了
![IMG_4716.PNG](http://7xqspl.com1.z0.glb.clouddn.com/image/8/24/13b8e501996c073b769f57f09549f.png)
![IMG_4718.PNG](http://7xqspl.com1.z0.glb.clouddn.com/image/b/53/55afc9860a0bec39bd1ff3685b3a2.png)

选中 系统应用 计算器

然后,打开计算器应用(如果已经是打开的,需要先退出它,重新进,才能看到效果)
![IMG_4719.PNG](http://7xqspl.com1.z0.glb.clouddn.com/image/0/86/52e2d16d49311d45941c6034b287c.png)

自此,我们的第一部分就结束了,通过本部分,我们了解了theos的基本配置,还有flex的越狱注入.
