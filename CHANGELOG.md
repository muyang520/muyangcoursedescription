# 课程更新记录

课程持续更新中，跟着行业走。

---
## 2026年3月

安卓新增：

- 14.3 逆向还原GrokAPP的算法并调用接口对话
  - 1.secp256k1密钥对生成与公钥压缩

  - 2.gRPC/Protobuf协议逆向与手写编码

  - 3.challenge-response匿名认证流程分析

  - 4.ECDSA签名：compact格式+Low-S规范化

  - 5.Python完整还原与流式gRPC响应解析

  - 6.MCP辅助逆向：jadxmcp+idapromcp实战

    

iOS新增:

- 8.ins_419.0.0最新版抓包
  - 1.Frida hook资源加载定位CACerts.plist 
  - 2.IDA交叉引用找到核心验证函数 
  - 3.Hook该函数返回0绕过SSL Pinning

  
  
- 12.1(Ai).AI工具入门_iOS版
  - 1.LLM基础概念 
  - 2.Cline+DeepSeek环境配置 
  - 3.逆向场景Prompt设计
  
  
  
- 12.2(Ai)Etxx_Swift签名算法逆向_x-etsy-signature

  - 通过 hook NSMutableURLRequest 定位签名 header 的设置位置
  - 使用 strings + grep 跨模块搜索关键字符串
  - AI + IDA（idapromcp）远程反编译与代码分析工作流
  - HMAC-SHA256 签名算法的识别与参数还原
  - Swift async/await 编译产物在 IDA 中的识别技巧

  

- 12.3(Ai)Etxx_设备指纹与链路追踪逆向

  - 通过 hook NSUserDefaults 系统方法定位本地缓存数据的写入来源
  - 使用 frida-trace 全量 trace 快速发现目标方法
  - 跨模块搜索（frameworks + 主二进制）定位字符串归属
  - UUID 生成设备指纹的常见套路（去横线、截取、转小写）
  - Sentry 分布式追踪协议（sentry-trace header）的格式与生成逻辑

  

- 12.4(Ai)Grok_iOS_从私钥到x-anonuserid_匿名身份逆向教案

  - 抓包定位需要重点逆向的请求头，区分硬编码字段、随机字段和持久化字段。
  - 通过 Frida Hook Keychain 读写，观察匿名凭证的保存、读取和重建时机。
  - 拆解 `CreateAnonUser` 请求与响应中的 gRPC 帧和 protobuf 结构，理解数据是怎样一层层打包的。
  - 从私钥生成、压缩公钥推导到 `x-anonuserid`，建立“本地身份生成”这一条主线。
  - 结合 IDA 静态分析、日志字符串和交叉引用，定位匿名身份初始化的关键函数链。
  - 用 Python 复现请求和响应解析，把抓包结论转成可验证、可运行的代码。

  

- 12.5(Ai)Grok_iOS_从x-challenge到x-signature_签名链路逆向
  - 拆解 `CreateAnonUserChallenge` 的 gRPC 请求与响应，确认 `x-challenge` 来自服务端而非客户端生成。
  - 通过 IDA 字符串搜索、交叉引用和日志定位，追踪出 `x-signature` 的生成流程：SHA256 + secp256k1 签名。
  - 手动拆解 protobuf tag 编码（单字节 tag vs 多字节 varint tag），从 hex 还原出 field number 和 wire type。
  - 识别 gRPC 流式响应是多个 length-prefixed frame 拼接，逐帧还原出 assistant 文本和元信息。
  - 串联 CreateAnonUser → CreateAnonUserChallenge → 签名 → CreateConversation → AddResponse 五步调用链，建立完整认证流程。
  - 用 Python 动态复现整条链路，从 `os.urandom(32)` 到收到 Grok 回复，零硬编码凭证。

---

## 2026年2月

安卓新增：

- 14.2Ai一键逆向某海外App签名实战
  - 1.AI自动抓包分析
  - 2.APK自动解压搜索
  - 3.AI定位关键代码
- 7.7Pinterest逆向分析
  - 1.mitmproxy抓包环境搭建与证书安装
  - 2.InstallId算法：UUID前26位+MD5校验后5位
  -  3.fields参数：GZIP+Base64编码的字段选择器
  -  4.B3链路追踪头生成：Zipkin协议与随机数 
  - 5.R8内联优化对Frida hook的影响与解决 
  - 6.逆向方法论：静态分析+动态hook配合

---

## 2026年1月

安卓新增：

- 13.6.BCC框架入门与BPF_HASH详解
  - 1.BCC框架Python+C混合编程
  - 2.BPF_HASH数据结构使用
  - 3.内核版本兼容性处理方案
- 13.7.BCC高级特性与数据传递机制
  - 1.BPF_PERF_OUTPUT事件输出
  - 2.Map/Perf/Ring三种数据传递对比
  - 3.uprobe用户态函数追踪实战
- 13.8.libbpf入门环境搭建
  - 1.BCC vs libbpf:编译型vs解释型
  - 2.libbpf CO-RE跨内核版本优势
  - 3.bootstrap项目环境搭建
- 13.9.libbpf核心示例与探针类型详解
  - 1.libbpf完整代码结构详解
  - 2.kprobe/uprobe/tp/raw_tp四种探针
  - 3.用户态与内核态数据交互机制
- 13.10.Android_eBpf实战开发-ssltrace
  - 1.BPF Maps核心数据类型
  - 2.CO-RE BTF跨版本兼容开发
  - 3.Android eBPF ssltrace抓包开发
- 14.1.AI工具入门与实战-Android版-教案
  - 1.AI辅助逆向分析
  - 2.Java层AI分析
  - 3.Native层AI分析

---

## 2025年12月

安卓新增：

- 13.1.eBPF入门与Linux环境搭建
  - 1.eBPF概念与内核态编程
  - 2.BCC在Ubuntu虚拟机环境搭建
  - 3.eBPF程序加载与验证流程
- 13.2.Android eBPF环境搭建与eCapture抓包
  - 模拟器与真机的BCC开发环境搭建
  - vscode远程开发环境搭建
  - ecapture无视证书安卓抓包
- 13.3.bpftrace语法基础与探针入门
  - 1.eBPF字节码验证与JIT编译
  - 2.bpftrace环境搭建与配置
  - 3.bpftrace探针语法与案例实操
- 13.4.bpftrace高级用法与实战脚本
  - 1.tracepoint与kprobe探针区别
  - 2.直方图与数据聚合分析
  - 3.调用栈追踪与结构体解引用
- 13.5.bpftrace Hook Android Native函数
  - 1.uprobe用户态函数探针原理
  - 2.map_files路径绕过技巧
  - 3.bpftrace Hook Native函数实操

---

## 2025年11月

安卓修改：

- 删除老的7.4
- 7.5实战 改到 7.4
- 7.6(实战)Java层定位常用方法总结_必看 改到 7.5

---

## 2025年10月

安卓新增：

- 11.2.4(综合实战)flutter逆向之某购物APP_sign分析
- 11.2.5(综合实战)flutter逆向之违法APP请求和返回加解密
- 11.5.1(综合实战)某海外二手APP_JWT分析
- 11.5.2(综合实战)某海外二手APP_protobuf分析

---

## 2025年9月

iOS修改名称：

- "8.1.1(综合实战)更新_Weee_sign算法解析" --> "8.1.1.1(入门案例)更新_Weee_sign算法解析"
- "8.1.2(综合实战)更新_快速定位的常用方法及脚本" --> "8.1.1.2(入门案例)更新_快速定位的常用方法及脚本"
- "8.1.3(综合实战)Weee_Sentry_逆向分析" --> "8.1.1.3(入门案例)Weee_Sentry_逆向分析"

iOS新增：

- 8.1.2.1(入门案例)某外卖配合AI定位加密算法
- 8.1.3.1(入门案例)某航空请求头加密rpc生成
- 8.1.4.1(入门案例)某appsign_魔改md5_请求体加密_返回体解密

---

## 2025年8月

安卓删除：

- 9.2反调试之过root检测-企业壳
- 9.3编译_编译与魔改面具
- 9.4frida检测的原理
- 9.6反调试过反frida调试
- 9.7ubuntu虚拟机安装配置及魔改frida过检测

安卓新增：

- 9.2(反调试)编译与魔改frida16.7.19
- 9.3(反调试)通用的frida过检测方案
- 9.4(反调试)补充frida反调试的一些原理以及小例子_envChek

---

## 2025年7月

iOS新增：

- 3.11(越狱插件Theos)使用Xcode调试Tweak插件以及附加所有app
- 8.4.1(AI开发逆向助手)开发思路和Theos插件开发
- 8.4.2(AI开发逆向助手)hook到的数据进行保存
- 8.4.3(AI开发逆向助手)巨魔app开发和助手ipa的开发思路
- 8.5.1(swift逆向)swift逆向介绍以及SwiftString的frida_hook参数和返回值替换
- 8.5.2(swift逆向)swift案例之某加密器算法还原

---

## 2025年6月

安卓和iOS同步更新，安卓在第八章，iOS在第五章，之前的1-10节课已经替换成新版本：

- 1(IDApro与arm汇编)IDAPro的基础使用介绍
- 2(IDApro与arm汇编)arm汇编基础与调试环境搭建
- 3(IDApro与arm汇编)操作系统基本原理
- 4(IDApro与arm汇编)arm架构及A64与A32的区别
- 5(IDApro与arm汇编)数据处理指令
- 6(IDApro与arm汇编)内存访问_堆栈_调用约定
- 7(IDApro与arm汇编)条件执行
- 8(IDApro与arm汇编)控制流
- 9(IDApro与arm汇编)静态分析_汇编算法还原_patchSo
- 10(IDApro与arm汇编)arm实现inlinehook

---

## 2025年4月

安卓新增：

- 11.4.1(综合实战)某样本SHA1魔改算法还原trace
  - 魔改SHA1算法还原
  - 分析unidbg Trace日志

iOS新增：

- 8.3.1(综合实战)某APP参数定位_内存漫游
  - frida内存漫游定位方法
- 8.3.2(综合实战)某APPchomper模拟执行和trace还原魔改SHA1
  - 使用chomper模拟执行iOS
  - 分析chomper Trace日志，魔改SHA1算法还原

---

## 2025年3月

iOS新增：

- 3.8.Theos与frida消除SpingBoard数字_UI调试插件
- 3.9Theos编写基于列表页面新增按钮
  - 新增组 在组里面添加一个控件
  - 在原组添加一个控件
  - 在当前页面控制器添加一个控件
- 3.10.按钮适配所有越狱_并开发功能
  - switch选择功能 && 对应的cell都需要有图片资源
  - 插件全适配所有越狱(rootfull,rootless,roothide)
  - 退出功能
  - 打开新的页面,弹出UIViewController

安卓新增：

- 5.34算法之RC4讲解
- 8.34算法之RC4讲解
- 11.2.1.flutter介绍以及抓包
- 11.2.2.flutter逆向实战_请求及返回加密解密
- 11.2.3.flutter逆向之RC4样本

安卓删除：

- 5(抓包攻防)9.某违法app_flutter抓包详讲

---

## 2025年2月

| 安卓逆向 | iOS逆向 |
| --- | --- |
|  | 5.26(汇编与算法)Demo魔改md5_1-16轮还原 |
|  | 5.27(汇编与算法)Demo魔改md5_余下轮还 |
| 8.28(so与算法原理)魔改SHA1算法还原 | 5.28(汇编与算法)魔改SHA1算法还原 |
| 8.29(so与算法原理)魔改SHA256算法还原 | 5.29(汇编与算法)魔改SHA256算法还原 |
| 8.30(so与算法原理)白盒AES入门 | 5.30(汇编与算法)白盒AES入门 |
| 8.31(so与算法原理)逆推AES密钥及差分故障原理 | 5.31(汇编与算法)逆推AES密钥及差分故障原理 |
| 8.32(so与算法原理)分析白盒AES源码 | 5.32(汇编与算法)分析白盒AES源码 |
| 8.33(so与算法原理)白盒AES-CTF案例实战 | 5.33(汇编与算法)白盒AES-CTF案例实战 |

---

## 2024年7月

安卓新增：

- 2(lsposed开发)12.界面与hook代码交互
- 2(lsposed开发)13.lsposed实现frida的Java.choose内存搜索功能
- 3(frida)15.hook实现接口方法的小技巧
- 12.26(反混淆)unidbg自动还原ollvm控制流平坦化
- 12.27(反混淆)IDA_trace环境搭建
- 12.28(反混淆)unidbg_trace_ollvm非标准算法还原_环境搭建
- 12.29(反混淆)unidbg_trace_ollvm非标准算法还原_input-middle
- 12.30(反混淆)unidbg_trace_ollvm非标准算法还原-middle_output
- 12.31(反混淆)frida-stalker-trace算法环境代码

iOS新增：

- 1.13(快速入门)无根越狱和有根越狱的区别
- 3.7(越狱插件Theos)前部分注意事项以及无根越狱插件编写
