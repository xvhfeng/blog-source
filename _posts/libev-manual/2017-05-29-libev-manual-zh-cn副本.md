---
layout: post
title: "libev 中文手册"
---

本文是libev英文版使用手册的中文翻译版。  
大概在2年前，在我第一次使用libev的时候，我发现关于libev的中文手册和中文使用说明很少，所以我就试着给作者发mail，希望作者能授权给我翻译中文手册的资格，但是至今未收到回音。所以我想做几点声明，如下：    
1. 此文的原始版权归原作者（libev的e文作者），而本文的任何权利都和e文文档的权利相同，包括开源协议；  
2. 本人不享有授权任何人分发（包括但不仅限于印刷、出版等）此文档的权利；  
3. 需要出版此文档必须经过原e文文档的同意；  

特此说明：  
对于一个e文极烂，4级都没有分数的人来说，翻译纯粹是靠毅力在支撑，但是水平有限是
现实问题，所以在翻译的过程中难免会有错误，请大家海涵，并且希望大家能在发现问题的
时候第一时间联系我。  

## libev

libev - a high performance full-featured event loop written in C.  
libev-一个用c写成的全功能事件循环库（PS：event loop不知道怎么翻译好）。  

## SYNOPSIS 简介

```
    #include <ev.h>
    EXAMPLE PROGRAM
    示例程序

    // a single header file is required
    //需要包含ev.h头文件
    #include <ev.h>

    #include <stdio.h> // for puts

    // every watcher type has its own typedef'd struct
    // with the name ev_TYPE
    //每一个观察者（watcher，以下还是用watcher吧，这种名称用中文很别扭）都有一个自己的结构体，结构体名称形如ev_TYPE

    ev_io stdin_watcher;
    ev_timer timeout_watcher;

    // all watcher callbacks have a similar signature
    // this callback is called when data is readable on stdin
    //所有的watcher回调函数也都有同样的函数签名
    //当stdin可读的时候，执行回调函数
    static void
    stdin_cb (EV_P_ ev_io *w, int revents)
    {
        puts ("stdin ready");
        // for one-shot events, one must manually stop the watcher
        // with its corresponding stop function.
        // 对于只发生一次的事件来说，我们必须使用watcher的相应停止函数来手动停止这个watcher
        //译者注：它的意思是对于只需要触发一次的事件，我们必须使用不同类型相应的函数来停止这个watcher在loop中继续被监视
       //PS: 对于IO事件就是ev_io_stop,对于time事件  就是ev_time_stop
        ev_io_stop (EV_A_ w);

        // this causes all nested ev_run's to stop iterating
        //停止loop的运行，释放全部的watcher
        ev_break (EV_A_ EVBREAK_ALL);
    }

    // another callback, this time for a time-out
    //另外一个回调函数，是时间过期调用的
    static void
    timeout_cb (EV_P_ ev_timer *w, int revents)
    {
        puts ("timeout");
        // this causes the innermost ev_run to stop iterating
        //停止当前loop循环
        ev_break (EV_A_ EVBREAK_ONE);
    }

    int
    main (void)
    {
        // use the default event loop unless you have special needs
        //除非你有特别的需求,一般使用默认的event loop即可
        struct ev_loop *loop = EV_DEFAULT;

        // initialise an io watcher, then start it
        // this one will watch for stdin to become readable
        //初始化一个io watcher，将事件和loop关联
        //这个watcher监视stdin是否可读
        ev_io_init (&stdin_watcher, stdin_cb, /*STDIN_FILENO*/ 0, EV_READ);
        ev_io_start (loop, &stdin_watcher);

        // initialise a timer watcher, then start it
        // simple non-repeating 5.5 second timeout
        //初始化一个超时watcher，并将事件和loop关联
        //简单的非重复5.5s超时
        ev_timer_init (&timeout_watcher, timeout_cb, 5.5, 0.);
        ev_timer_start (loop, &timeout_watcher);

        // now wait for events to arrive
        //开始监听事件
        ev_run (loop, 0);

        // break was called, so exit
        return 0;
    }

```

## ABOUT THIS DOCUMENT 关于这个文档  

This document documents the libev software package.  
这份文档记录了libev这个软件开发包。  

The newest version of this document is also available as an html-formatted web page you might find easier to navigate when reading it for the first time: http://pod.tst.eu/http://cvs.schmorp.de/libev/ev.pod.  
这个文档最新的版本是一个html，你可以在这里找到它：[最新的e文文档](http://pod.tst.eu/http://cvs.schmorp.de/libev/ev.pod.).  


While this document tries to be as complete as possible in documenting libev, its usage and the rationale behind its design, it is not a tutorial on event-based programming, nor will it introduce event-based programming with libev.  
这篇文档试着尽可能详细的说明libev的使用方法及其背后的设计理念，所以这不是一个基于事件编程的教程，也不会使用libev来教导事件编程.  

Familiarity with event based programming techniques in general is assumed throughout this document.  
这篇文档假定你已经熟悉基于事件的编程技术  

## WHAT TO READ WHEN IN A HURRY

This manual tries to be very detailed, but unfortunately, this also makes it very long. If you just want to know the basics of libev, I suggest reading ANATOMY OF A WATCHER, then the EXAMPLE PROGRAM above and look up the missing functions in GLOBAL FUNCTIONS and the ev_io and ev_timer sections in WATCHER TYPES.  
这个手册试着说明的非常详细，但不幸的是，这也将让它变的很长。如果你只是想了解libev的基础知识，我建议读ANATOMY OF A WATCHER章节。示例程序在它上面，缺少的函数在GLOBAL FUNCTIONS章节中找，ev_io和ev_timer部分在WATCHER TYPES章节


## ABOUT LIBEV 关于libev

Libev is an event loop: you register interest in certain events (such as a file descriptor being readable or a timeout occurring), and it will manage these event sources and provide your program with events.  
libev是一个事件循环（event loop看上去还是舒服一些），你可以注册一些你感兴趣的事件（比如一个文件描述符可读事件或者一个超时事件），它可以管理这些事件源并且调用你的事件处理函数（其实就是callback你注册的事件处理函数).  

To do this, it must take more or less complete control over your process (or thread) by executing the event loop handler, and will then communicate events via a callback mechanism.  
要达到这样的目的，必须通过一个event loop事件句柄尽可能的完全控制你的进程（或者线程），然后通过一个回调机制通知事件处理函数。  

You register interest in certain events by registering so-called event watchers, which are relatively small C structures you initialise with the details of the event, and then hand it over to libev by starting the watcher.  
你通过注册所谓的事件观察者（event watcher）来注册一些你感兴趣的事件，这些watcher是一些你使用事件的详细信息来初始化的相对较小的c结构体，然后你通过开始watcher把它交给libev管理。  

## FEATURES 特性

Libev supports select, poll, the Linux-specific epoll, the BSD-specific kqueue and the Solaris-specific event port mechanisms for file descriptor events (ev_io), the Linux inotify interface (for ev_stat), Linux eventfd/signalfd (for faster and cleaner inter-thread wakeup (ev_async)/signal handling (ev_signal)) relative timers (ev_timer), absolute timers with customised rescheduling (ev_periodic), synchronous signals (ev_signal), process status change events (ev_child), and event watchers dealing with the event loop mechanism itself (ev_idle, ev_embed, ev_prepare and ev_check watchers) as well as file watchers (ev_stat) and even limited support for fork events (ev_fork).  
libev为文件描述符事件（ev_io）提供select，poll，linux特有的epoll，bsd特有的kqueue和solaris特有的event port机制，ev_stat使用的是linux的inotify接口（是不是别的平台就不提供？），linux eventfd/signalfd（为了更快更简洁（这里cleaner翻译成简洁应该更好）的线程间唤醒（ev_async）/信号事件（ev_signal)，相对的定时器（ev_timer），可自定义的绝对定时器（ev_periodic），同步信号（ev_signal)，进程状态的改变事件（ev_child），和一些event loop机制处理event watcher时自己带有的一些事件（ev_idle,ev_embed,ev_prepare和ev_check watcher)以及文件状态的watcher和fork一个子进程。  
译者注：其实这段就是告诉你libev有哪一些事件，有点啰嗦，来一个简单  
ev_io // IO可读可写  
ev_stat // 文件属性变化  
ev_async // 激活线程  
ev_signal // 信号处理  
ev_timer // 定时器  
ev_periodic // 周期任务  
ev_child // 子进程状态变化  
ev_fork // 开辟进程  
ev_cleanup // event loop退出触发事件  
ev_idle // 每次event loop空闲触发事件  
ev_embed // 用于将一个事件循环嵌套到另一个中，当事件循环处理事件的时候被调用  
ev_prepare // 每次event loop之前事件  
ev_check // 每次event loop之后事件  

It also is quite fast (see this benchmark comparing it to libevent for example).  
libev也是相当快的（可以见以libevent为例的基准比较）  

## CONVENTIONS 约定

Libev is very configurable. In this manual the default (and most common) configuration will be described, which supports multiple event loops. For more info about various configuration options please have a look at EMBED section in this manual. If libev was configured without support for multiple event loops, then all functions taking an initial argument of name loop (which is always of type struct ev_loop *) will not have this argument.  
libev是很容易配置的，在这份手册中，默认（也是最常见的）的配置将会被说明，libev也支持多个event loop。需要更多关于各种配置文件的选项，请查看手册的EMBED部分。如果libev被配置成不支持多个event loop，那么所有函数如果有一个名字为loop的参数，那么这个参数将不存在。（译者注：其实就是进程中只有一个event loop的话，event loop将会是一个常量，不需要在函数间传来传去，故这个参数将不存在）。  

## TIME REPRESENTATION

Libev represents time as a single floating point number, representing the (fractional) number of seconds since the (POSIX) epoch (in practice somewhere near the beginning of 1970, details are complicated, don't ask). This type is called ev_tstamp, which is what you should use too. It usually aliases to the double type in C. When you need to do any calculations on it, you should treat it as some floating point value.  
libev使用一个有符号（这里的single是译做单精度呢？还是译做单个呢？还是译做有符号？）的浮点数表示时间，表示至unix时间点（其实就是posix的标准时间点，在实践中差不多使用1970年开始的，详细的算法很复杂，不要多问）以来经过的秒数。这种时间类型被叫做ev_tstamp，也是你将要使用的类型。这种类型在c中经常被叫做double，当你需要使用它做任何计算的时候，你应该把他作为浮点数对待。  

Unlike the name component stamp might indicate, it is also used for time differences (e.g. delays) throughout libev.  
不像’stamp’这个名称所指出的那样，ev_tstamp也可以用来表示时间差（这句来自左手）  
译者注：这句话不知道怎么翻译，可能是他要表示libev使用ev_tstamp表示libev的时间间隔。  

## ERROR HANDLING 错误处理

Libev knows three classes of errors: operating system errors, usage errors and internal errors (bugs).  
libev知道3种错误：系统错误，用法错误和内部错误。   

When libev catches an operating system error it cannot handle (for example a system call indicating a condition libev cannot fix), it calls the callback set via ev_set_syserr_cb, which is supposed to fix the problem or abort. The default is to print a diagnostic message and to call abort ().  
当libev捕获一个它不能处理的系统错误时（例如一个系统调用说明一个条件，libev不能处理它。这句怪怪的，其实就是一个libev不能处理的系统调用），libev就会调用一个你通过sv_set_syserr_sb设置的回调函数，这个回调函数提供处理这个错误的方法或者终止libev，libev默认的回调函数是打印错误消息，并且调用abort函数。  

When libev detects a usage error such as a negative timer interval, then it will print a diagnostic message and abort (via the assert mechanism, so NDEBUG will disable this checking): these are programming errors in the libev caller and need to be fixed there.  
当libev检测到一个错误的使用方法时，比如一个负的时间间隔（从现实生活角度出发，貌似负的时间间隔应该可以啊？），libev会打印一个诊断消息并且终止程序（通过assert机制，NODEBUG将会关闭这个检查）；这些都是libev的调用者的编程错误（其实就是来自于程序员的），这些错误必须要防止它。  

Libev also has a few internal error-checking assertions, and also has extensive consistency checking code. These do not trigger under normal circumstances, as they indicate either a bug in libev or worse.  
libev也有一些内部错误检查的机制，并且拥有广泛的一致性检查代码，他们不会在正常情况下触发，当他们触发时就表明libev发生了一个bug或者是更糟的情况。  

## GLOBAL FUNCTIONS 全局函数

These functions can be called anytime, even before initialising the library in any way.  
这些函数可以在任何时候被调用，甚至在libev这个库初始化之前（应该是在libev的事件驱动初始化之前吧）。  

### ev_tstamp ev_time ()  
Returns the current time as libev would use it. Please note that the ev_now function is usually faster and also often returns the timestamp you actually want to know. Also interesting is the combination of ev_now_update and ev_now.  
当libev调用它的时候返回当前的时间。请注意：ev_now函数经常会更快，并且它也经常返回你真正需要的时间戳。更有趣的是ev_now_update和ev_now的组合。（译者注：和nginx一样，libev有一个自己的时间管理机制，你在调用ev_now之前先调用一下ev_now_update这样会得到更加精确的时间）。  

### ev_sleep (ev_tstamp interval)  
Sleep for the given interval: The current thread will be blocked until either it is interrupted or the given time interval has passed (approximately - it might return a bit earlier even if not interrupted). Returns immediately if interval <= 0.  
休眠给定的时间。当前线程将会被阻塞直到它被中断或者给定的时间到。（大概的，如果线程没有被中断，它可能会比规定时间早醒来一些）。如果给定时间小于0，立即返回。  

Basically this is a sub-second-resolution sleep ().  
基本上，这是一个低精度的休眠。  

The range of the interval is limited - libev only guarantees to work with sleep times of up to one day (interval <= 86400).  
规定的时间是有限制的，libev只保证最多一天的线程休眠时间。  

### int ev_version_major ().  
### int ev_version_minor ()   
You can find out the major and minor ABI version numbers of the library you linked against by calling the functions ev_version_major and ev_version_minor. If you want, you can compare against the global symbols EV_VERSION_MAJOR and EV_VERSION_MINOR, which specify the version of the library your program was compiled against.  
通过调用ev_version_major和ev_version_minor函数，你可以知道你所连接的libev库的主要和次要版本号。如果你想要，你可以和EV_VERSION_MAJOR和EV_VERSION_MINOR比较版本号。这两个指定你编译的库的版本号。  

These version numbers refer to the ABI version of the library, not the release version.  
这些版本号是指库的ABI版本，不是发行版的版本。  

Usually, it's a good idea to terminate if the major versions mismatch, as this indicates an incompatible change. Minor versions are usually compatible to older versions, so a larger minor version alone is usually not a problem.  
通常，如果主版本号不同，终止程序是一个好的办法。因为这表明有不兼容的代码变更。子版本号经常会兼容老版本，所以一些更大的子版本号通常都不是一个问题。  

Example: Make sure we haven't accidentally been linked against the wrong version (note, however, that this will not detect other ABI mismatches, such as LFS or reentrancy).  
例如：你要确保我们没有意外的连接错误的版本号（注意，不管怎么样，这些不能检测到其他的ABI不匹配，比如LFS和重入性等等）  

```
    assert (("libev version mismatch",
    ev_version_major () == EV_VERSION_MAJOR
    && ev_version_minor () >= EV_VERSION_MINOR));
```

### unsigned int ev_supported_backends ()  
Return the set of all backends (i.e. their corresponding EV_BACKEND_* value) compiled into this binary of libev (independent of their availability on the system you are running on). See ev_default_loop for a description of the set values.  
返回编译到libev中的loop支持的所有的后台处理器集合（它们就是EV_BACKEND_ *的值）。具体请查看ev_DEFAULT_loop设置值说明。  


Example: make sure we have the epoll method, because yeah this is cool and a must have and can we have a torrent of it please!!!  
例如：请确保我们有epoll方法，因为epoll非常酷并且必须有也可以让我们有epoll的并发能力。  

```
assert (("sorry, no epoll, no sex",
ev_supported_backends () & EVBACKEND_EPOLL));
```

### unsigned int ev_recommended_backends ()  
Return the set of all backends compiled into this binary of libev and also recommended for this platform, meaning it will work for most file descriptor types. This set is often smaller than the one returned by ev_supported_backends, as for example kqueue is broken on most BSDs and will not be auto-detected unless you explicitly request it (assuming you know what you are doing). This is the set of backends that libev will probe for if you specify no backends explicitly.  
返回所有编译进当前libev中并且推荐给当前操作系统平台为大多数文件描述符工作的后台集合。这个集合经常小于ev_supported_backends的返回值。例如：kqueue是被大多数BSDs排斥的，并且不会被自动的检测到除非你现实的说明需要它（假设你知道你自己在做什么）（译者注：其实很奇怪，kqueue不是就是BSDs系支持的嘛？为什么不会被自动的探测到？而是要自己显示的手动设置？）。这个后端集合就是libev将要探测的并且不是你显示的指定的。  

### unsigned int ev_embeddable_backends ()  
Returns the set of backends that are embeddable in other event loops. This value is platform-specific but can include backends not available on the current system. To find which embeddable backends might be supported on the current system, you would need to look at ev_embeddable_backends () & ev_supported_backends (), likewise for recommended ones.  
返回嵌入在其他event loop中的后台集合。这个值是特定于平台的，但是可以包括那些当前平台没有的后台。若要查找那些嵌入的后台可能会被当前系统提供，你需要你看ev_embeddable_backends () & ev_supported_backends ()。同样，这也是推荐使用的。  

See the description of ev_embed watchers for more info.  
请参阅ev_embed watcher获取更多的信息。  

### ev_set_allocator (size) throw ()  
Sets the allocation function to use (the prototype is similar - the semantics are identical to the realloc C89/SuS/POSIX function). It is used to allocate and free memory (no surprises here). If it returns zero when memory needs to be allocated (size != 0), the library might abort or take some potentially destructive action.  
设置要使用的内存分配函数（原型和语义都是和C89/Sus/POSIX的realloc函数完全相同）。他被用来申请和释放内存（这里没有特殊）。如果当函数需要分配（size ！＝0）的内存时返回0，libev将会被终止或者就会有一些潜在的破坏错误会发生。  

Since some systems (at least OpenBSD and Darwin) fail to implement correct realloc semantics, libev will use a wrapper around the system realloc and free functions by default.  
由于某些系统（至少OpenBSD和Darwin）没有实现语义完全正确（译者注：应该是和POSIX标准相同）的realloc函数，libev会默认使用系统realloc和free函数的包装。  

You could override this function in high-availability programs to, say, free some memory if it cannot allocate memory, to use a special allocator, or even to sleep a while and retry until some memory is available.  
你可以在高性能程序中重写这个函数。如果它不能申请内存就先释放一下，使用一个特殊的分配器或者休眠一会儿然后重试，直到申请内存成功。  

Example: Replace the libev allocator with one that waits a bit and then retries (example requires a standards-compliant realloc).  
例子：使用短暂休眠和重试分配（例如需要一个符合规范的分配器）的替换libev的分配器。  

```
static void *
persistent_realloc (void *ptr, size_t size) {
    for (;;) {
        void *newptr = realloc (ptr, size);
        if (newptr)
            return newptr;
        sleep (60);
    }
}
...
ev_set_allocator (persistent_realloc);
```

### ev_set_syserr_cb (void (*cb)(const char *msg) throw ())  
Set the callback function to call on a retryable system call error (such as failed select, poll, epoll_wait). The message is a printable string indicating the system call or subsystem causing the problem. If this callback is set, then libev will expect it to remedy the situation, no matter what, when it returns. That is, libev will generally retry the requested operation, or, if the condition doesn't go away, do bad stuff (such as abort).  
设置一个系统调用被调用出错时可以调用的打印回调函数（比如错误的select，poll，epoll_wait）。
消息是一个可打印的字符串，其说明了系统调用或者是子系统调用所发生的问题。如果设置了这个回调，libev不管在什么情况下，当它返回的时候都会期望这个函数可以用来补救错误。通常，libev会重试请求操作，但是如果条件不再可以执行，程序就会出错（比如终止程序）。  

Example: This is basically the same thing that libev does internally, too.  
例如：这也是libev内部基本的处理方案。  

```
static void
fatal_error (const char *msg) {
    perror (msg);
    abort ();
}

...
ev_set_syserr_cb (fatal_error);

```

### ev_feed_signal (int signum)  
This function can be used to "simulate" a signal receive. It is completely safe to call this function at any time, from any context, including signal handlers or random threads.  
可以使用这个函数来模拟接收信号。任何时候，任何程序上下文（context），包括信号处理事件和随便哪一个线程中调用这个函数都是完完全全安全的。  


Its main use is to customise signal handling in your process, especially in the presence of threads. For example, you could block signals by default in all threads (and specifying EVFLAG_NOSIGMASK when creating any loops), and in one thread, use sigwait or any other mechanism to wait for signals, then "deliver" them to libev by calling ev_feed_signal.  
它主要用来在进程中处理客户自定义的信号处理程序，尤其是涉及到多线程的信号处理。例如：默认的，你可以在所有线程中（和当你创建loop时指定EVFLAG_NOSIGMASK的信号）阻塞信号，在一个线程中，使用sigwait或者另外别的机制来等待信号。然后使用ev_feed_signal通知到libev。  

## FUNCTIONS CONTROLLING EVENT LOOPS  控制event loops的函数  

An event loop is described by a struct ev_loop * (the struct is not optional in this case unless libev 3 compatibility is disabled, as libev 3 had an ev_loop function colliding with the struct name).  
通过一个ev_loop结构体的指针来描述一个event loop。（通常情况下，这个结构体不是可选的，除非把libev 3的兼容性禁止掉，因为libev 3有一个ev_loop的函数和这个结构体重名。）  

The library knows two types of such loops, the default loop, which supports child process events, and dynamically created event loops which do not.  
libev支持两种类型的loop，默认的loop，支持子进程事件；动态创建的则不支持子进程事件。  

### struct ev_loop *ev_default_loop (unsigned int flags)  
This returns the "default" event loop object, which is what you should normally use when you just need "the event loop". Event loop objects and the flags parameter are described in more detail in the entry for ev_loop_new.  
该函数返回默认的event loop对象，这个默认的设置通常就是你所需要使用的。event loop对象的状态参数和详细描述请参阅ev_loop_new函数。  

If the default loop is already initialised then this function simply returns it (and ignores the flags. If that is troubling you, check ev_backend () afterwards). Otherwise it will create it with the given flags, which should almost always be 0, unless the caller is also the one calling ev_run or otherwise qualifies as "the main program”.  
当函数无参数调用返回的时候，默认的loop就已经初始化了（忽略一切设置，只是简单的调用此函数，如果你不放心，后续可以调用ev_backend（）函数检查）。否则此函数将按照给定的flag创建loop，其实这些flag通常都是设置为0，除非调用者也调用ev_run，也就是说是主程序调用。（译者注：主程序有什么差别吗？）  

If you don't know what event loop to use, use the one returned from this function (or via the EV_DEFAULT macro).  
如果你不知道到底用什么来初始化你的event loop，那么就使用这个函数默认返回的（或者通过EV_DEFAULT宏）。  

Note that this function is not thread-safe, so if you want to use it from multiple threads, you have to employ some kind of mutex (note also that this case is unlikely, as loops cannot be shared easily between threads anyway).  
注意：此函数不是线程安全的，所以如果你想在多线程环境中使用，你需要使用某种mutex的锁（还要注意：在线程间简单的共享这个loop是不可能的）。  

The default loop is the only loop that can handle ev_child watchers, and to do this, it always registers a handler for SIGCHLD. If this is a problem for your application you can either create a dynamic loop with ev_loop_new which doesn't do that, or you can simply overwrite the SIGCHLD signal handler after calling ev_default_init.  
默认的loop是全局唯一的，此loop也可以处理ev_child的watchers（其实就是处理子进程的事件），要实现这个功能，通常要先注册一个SIGCHLD信号事件。如果对于你的应用程序全局loop有问题的话，你可以在调用ev_default_init函数后重写一下SIGCHLD信号处理函数。  

Example: This is the most typical usage.  
示例：这是最典型的用法。  

```
if (!ev_default_loop (0))
fatal ("could not initialise libev, bad $LIBEV_FLAGS in environment?");
```

Example: Restrict libev to the select and poll backends, and do not allow environment settings to be taken into account:  
示例：限制loop使用select和poll作为后端，并且不允许更改这个账号的环境设置。  

```
ev_default_loop (EVBACKEND_POLL | EVBACKEND_SELECT | EVFLAG_NOENV);
```

### struct ev_loop *ev_loop_new (unsigned int flags)  
This will create and initialise a new event loop object. If the loop could not be initialised, returns false.  
此函数将创建并且初始化一个新的event loop对象。如果loop不能被初始化，函数返回false。  

This function is thread-safe, and one common way to use libev with threads is indeed to create one loop per thread, and using the default loop in the "main" or "initial" thread.  
此函数是线程安全的，是一个在多线程环境中通常使用libev的方式：每一个线程创建一个loop，然后在主线程或者初始化线程中使用默认的loop。  

The flags argument can be used to specify special behaviour or specific backends to use, and is usually specified as 0 (or EVFLAG_AUTO).  
flag参数可以被用来指定特殊的行为或者指定使用的后台，通常，flag设置成0（或者EVFLAG_AUTO)。  

The following flags are supported:  
这些flags提供的选项：  

#### EVFLAG_AUTO
The default flags value. Use this if you have no clue (it's the right thing, believe me).  
默认的值，如果你没有什么特殊的要求，就用这个选项（相信我，这是对的）。  

#### EVFLAG_NOENV
If this flag bit is or'ed into the flag value (or the program runs setuid or setgid) then libev will not look at the environment variable LIBEV_FLAGS. Otherwise (the default), this environment variable will override the flags completely if it is found in the environment. This is useful to try out specific backends to test their performance, to work around bugs, or to make libev threadsafe (accessing environment variables cannot be done in a threadsafe way, but usually it works if no other thread modifies them).  
如果flag位被设置（或者程序执行setuid或者setgid），libev将不会去查看LIBEV_FLAGS这个环境变量。否则（默认的），如果这个环境变量被找到，它将会完整的覆盖这个flag位。对于设置指定的后台来测试性能、解决bug、或者让libev线程安全（访问环境变量是线程不安全的，但是如果别的线程不更改他们，他们通常一切ok），这很有用。  

#### EVFLAG_FORKCHECK
Instead of calling ev_loop_fork manually after a fork, you can also make libev check for a fork in each iteration by enabling this flag.  
通常你需要在fork函数后显式的调用ev_loop_fork函数，但是你也可以通过设置这个flag来使libev在每次迭代的时候检查fork（）。  

This works by calling getpid () on every iteration of the loop, and thus this might slow down your event loop if you do a lot of loop iterations and little real work, but is usually not noticeable (on my GNU/Linux system for example, getpid is actually a simple 5-insn sequence without a system call and thus very fast, but my GNU/Linux system also has pthread_atfork which is even faster).  
这是通过在loop的每次迭代中调用getpid（）来实现的。因此，如果你大部分在做loop的迭代，小部分在做业务操作，它将会减慢一点event loop的速度。但是这通常是不需要担心的（以在我的GNU/LINUX系统上为例，getpid通常在没有系统调用的情况下被连续执行5次，这是很快的，我的GNU/LINUX系统也有pthread_atfork，它更快）。  

The big advantage of this flag is that you can forget about fork (and forget about forgetting to tell libev about forking) when you use this flag.  
当你使用这个flag位的时候，最大的好处是你可以忘记fork（忘掉忘记了告诉libev forking）。  

This flag setting cannot be overridden or specified in the LIBEV_FLAGS environment variable.  
设置这个flag不能覆盖或者指定LIBEV_FLAGS环境变量。  

#### EVFLAG_NOINOTIFY
When this flag is specified, then libev will not attempt to use the inotify API for its ev_stat watchers. Apart from debugging and testing, this flag can be useful to conserve inotify file descriptors, as otherwise each loop using ev_stat watchers consumes one inotify handle.  
如果指定这个flag。libev将不会尝试使用inotify api来作为其ev_stat的watchers。除了调试和测试，这个flag将会用来节约inotify的文件描述符，否则每个loop使用ev_stat watchers消耗一个inotify句柄。（译者注：这里应该是每个loop一个描述符而不是每次迭代一个吧？）  

#### EVFLAG_SIGNALFD
When this flag is specified, then libev will attempt to use the signalfd API for its ev_signal (and ev_child) watchers. This API delivers signals synchronously, which makes it both faster and might make it possible to get the queued signal data. It can also simplify signal handling with threads, as long as you properly block signals in your threads that are not interested in handling them.  
当此flag被设置时，libev尝试为它的ev_signal（和ev_child）使用signalfd API。这个API提供信号同步，并且让它更快，也可能可以得到排列的信号数据（译者注：是得到信号通知嘛？）它也可以简化线程的信号处理，只要你正确的在你的线程间阻塞你的信号就不会去处理他们。（译者注：这句话怎么怪怪的，有更好的翻译嘛？）  

Signalfd will not be used by default as this changes your signal mask, and there are a lot of shoddy libraries and programs (glib's threadpool for example) that can't properly initialise their signal masks.  
默认情况下，signalfd将不会被使用，因为这会更改你的信号掩码。有很多的劣质库和程序（比如glib的线程池）不能正确的初始化他们的信号掩码。  

#### EVFLAG_NOSIGMASK
When this flag is specified, then libev will avoid to modify the signal mask. Specifically, this means you have to make sure signals are unblocked when you want to receive them.  
当设置这个flag时，libev将不会修改信号掩码。具体来说，这意味着你必须在想要接收它们是，确保信号没有被阻塞。  

This behaviour is useful when you want to do your own signal handling, or want to handle signals only in specific threads and want to avoid libev unblocking the signals.  
当你想要自己处理信号，或者想要在特定的线程中处理信号和想要避免让libev疏导信号时，这种行为很有用。  

It's also required by POSIX in a threaded program, as libev calls sigprocmask, whose behaviour is officially unspecified.  
在一个POSIX多线程程序中这是必须的，当libev调用sigprocmask，其行为是未定义的。  

This flag's behaviour will become the default in future versions of libev.  
这个flag的行为将来在libev中将会变成默认的。  

#### EVBACKEND_SELECT (value 1, portable select backend)  轻量级后台
This is your standard select(2) backend. Not completely standard, as libev tries to roll its own fd_set with no limits on the number of fds, but if that fails, expect a fairly low limit on the number of fds when using this backend. It doesn't scale too well (O(highest_fd)), but its usually the fastest backend for a low number of (low-numbered :) fds.  
这是标准的select（2）后台，不完全标准的，因为libev试着推行自己的不带fds数量限制的fd_set。但是如果失败，当使用这个后台的时候，预计fds会有很小数量的限制。它通常不能很好的扩展，但是如果fds非常小，它通常是最快的后台。  

To get good performance out of this backend you need a high amount of parallelism (most of the file descriptors should be busy). If you are writing a server, you should accept () in a loop to accept as many connections as possible during one iteration. You might also want to have a look at ev_set_io_collect_interval () to increase the amount of readiness notifications you get per iteration.  

This backend maps EV_READ to the readfds set and EV_WRITE to the writefds set (and to work around Microsoft Windows bugs, also onto the exceptfds set on that platform).  
为了得到这个后台更好的性能，你需要大量的并行运行（大多数的文件描述符是忙碌的）。如果你正在写一个服务器，你必须在loop中调用accept来在一次迭代中尽可能多的接收更多的连接。你可能还需要看看ev_set_io_collect_interval（）来增加每次迭代中准备通知的数量。
这个后台映射EV_READ到readfds集合，映射EV_WRITE到writefds集合（并解决MS win平台上的bugs，也可以在别的平台上映射)  

#### EVBACKEND_POLL (value 2, poll backend, available everywhere except on windows)  （value 2，除win以外的所有平台）
And this is your standard poll(2) backend. It's more complicated than select, but handles sparse fds better and has no artificial limit on the number of fds you can use (except it will slow down considerably with a lot of inactive fds). It scales similarly to select, i.e. O(total_fds). See the entry for EVBACKEND_SELECT, above, for performance tips.  
这是标准的poll后台，它比select更复杂，但是处理量小的fds更好选择，并且没有人为的可用fds数量限制（除了他会减慢很多不活动的fdfs）。它的复杂度和select是一样的，即O（total_fds）。请参见上面EVBACKEND_SELECT条目，及其性能小技巧。  

This backend maps EV_READ to POLLIN | POLLERR | POLLHUP, and EV_WRITE to POLLOUT | POLLERR | POLLHUP.  
这个后台映射EV_READ到POLLIN | POLLERR | POLLHUP，映射EV_WRITE到POLLOUT | POLLERR | POLLHUP。  

#### EVBACKEND_EPOLL (value 4, Linux)
Use the linux-specific epoll(7) interface (for both pre- and post-2.6.9 kernels).  
使用linux特有的epoll（7）接口（支持2.6.9内核以上）。  

For few fds, this backend is a bit little slower than poll and select, but it scales phenomenally better. While poll and select usually scale like O(total_fds) where total_fds is the total number of fds (or the highest fd), epoll scales either O(1) or O(active_fds).  
对于一些文件描述符，这个后台相比poll和select是相对会慢一些，但是他的扩展性惊人的好。poll和select的复杂度经常是O（total_fds），total_fds是所有文件描述符的总数（或者是值最大的那个文件描述符），epoll复杂度是O（1）或者O（active_fds：活动的文件描述符）。  

The epoll mechanism deserves honorable mention as the most misdesigned of the more advanced event mechanisms: mere annoyances include silently dropping file descriptors, requiring a system call per change per file descriptor (and unnecessary guessing of parameters), problems with dup, returning before the timeout value, resulting in additional iterations (and only giving 5ms accuracy while select on the same platform gives 0.1ms) and so on. The biggest issue is fork races, however - if a program forks then both parent and child process have to recreate the epoll set, which can take considerable time (one syscall per file descriptor) and is of course hard to detect.  
作为在众多高级event机制中设计最失误的事件机制，epoll机制是值得拥有该”荣誉“的。失误仅仅包括：文件描述符默默的退出；每次更改一个文件描述符都需要一个系统调用（参数不必要的猜测），dup问题；在超时前返回值，从而导致更多的迭代（只有5ms的精确性，如果使用select，精度可以达到0.1ms），等等。最大的问题是交叉fork，如果程序fork，父子进程都需要重新设置epoll，这需要花费很多时间（每个文件描述符都需要一次系统调用），这当然是很难应对的。  

Epoll is also notoriously buggy - embedding epoll fds should work, but of course doesn't, and epoll just loves to report events for totally different file descriptors (even already closed ones, so one cannot even remove them from the set) than registered in the set (especially on SMP systems). Libev tries to counter these spurious notifications by employing an additional generation counter and comparing that against the events to filter out spurious ones, recreating the set when required. Epoll also erroneously rounds down timeouts, but gives you no way to know when and by how much, so sometimes you have to busy-wait because epoll returns immediately despite a nonzero timeout. And last not least, it also refuses to work with some file descriptors which work perfectly fine with select (files, many character devices…).  
epoll当然也是多bug的。设置到epoll的文件描述符应该是可以正常运行的，但是，当然也有不正常的时候，epoll只是喜欢报告注册在epoll（特别是指SMP系统上）中的那些完全不同的文件描述符事件（甚至包括已经关闭的文件描述符，所以，我们不能从设置集中移除他们）。epoll通过增加一个代计数器并且比较他们来过滤掉那些来自epoll报告的虚通知，重新建立那些报告的文件描述符集合，从而试图解决虚通知的问题。epoll还错误的向下舍入超时时间，但是不给你任何方法知道何时发生向下舍入和有多少文件描述符受影响，所以有的时候你不得不忙碌的等待着，因为epoll会立即返回超时的非零文件描述符。而最后的一点，它有的时候不支持那些能正常使用select机制的文件描述符（文件，很多的字符设备驱动）。  

Epoll is truly the train wreck among event poll mechanisms, a frankenpoll, cobbled together in a hurry, no thought to design or interaction with others. Oh, the pain, will it ever stop…  
epoll在事件机制中是真正的投票机制，一个基因改造的poll。epoll在匆忙中拼凑起来，没有设计和考虑和别的配合。oh，无语了。（这段怎么纯粹是作者的吐槽？看样子被折磨的不清）  

While stopping, setting and starting an I/O watcher in the same iteration will result in some caching, there is still a system call per such incident (because the same file descriptor could point to a different file description now), so its best to avoid that. Also, dup ()'ed file descriptors might not work very well if you register events for both file descriptors.  
当在同一个迭代中停止、设置和开始一个IO watcher时会导致一些缓存。这仍旧是每个这样的事件一个系统调用（因为现在相同的文件描述符可以指向不同的文件描述了），所以我们最好要避免这些。如果你注册两个相同的文件描述符事件，dup（）的文件描述符事件可能会不能正常运行。  

Best performance from this backend is achieved by not unregistering all watchers for a file descriptor until it has been closed, if possible, i.e. keep at least one watcher active per fd at all times. Stopping and starting a watcher (without re-setting it) also usually doesn't cause extra overhead. A fork can both result in spurious notifications as well as in libev having to destroy and recreate the epoll object, which can take considerable time and thus should be avoided.  
这个后台的最佳性能是通过不注销所有文件描述符的watchers直到他们被关闭来实现的。如果可能话，尽可能的保证任何时候每个fd至少一个watcher。停止和启动watcher（必须要重新设置它）一般也不会造成额外的开销。在libev中，fork既可以导致虚通知，又导致libev不得不释放和重新创建epoll对象，这是非常耗时的，所以尽量避免。  

All this means that, in practice, EVBACKEND_SELECT can be as fast or faster than epoll for maybe up to a hundred file descriptors, depending on the usage. So sad.
所有的这些都表明，在实践中，EVBACKEND_SELECT是可以快的，或者在100文件描述符之内相比epoll更快，具体取决于实际情况，不要对select太悲观。

While nominally embeddable in other event loops, this feature is broken in all kernel versions tested so far.
当显式的设置到另外一个event loop时，这些功能到目前为止是在任何内核版本中都是被禁止的。

This backend maps EV_READ and EV_WRITE in the same way as EVBACKEND_POLL.
后台把EV_READ和EV_WRITE全部映射到EVBACKEND_POLL。

EVBACKEND_KQUEUE (value 8, most BSD clones)
Kqueue deserves special mention, as at the time of this writing, it was broken on all BSDs except NetBSD (usually it doesn't work reliably with anything but sockets and pipes, except on Darwin, where of course it's completely useless). Unlike epoll, however, whose brokenness is by design, these kqueue bugs can (and eventually will) be fixed without API changes to existing programs. For this reason it's not being "auto-detected" unless you explicitly specify it in the flags (i.e. using EVBACKEND_KQUEUE) or libev was compiled on a known-to-be-good (-enough) system like NetBSD.
写这篇文章的时候，kqueue是特别值得一提的，kqueue在除了NetBSD的所有BSD系统上都会出现问题。（通常kqueue不能可靠的运行，但是sockets和pipes除外。除了在Darwin上，kqueue是完全没有用处的。译者注：这tmd到底要表达意思？）。不像epoll，kqueue的问题是因为设计，不管怎么说，这些kqueue的bugs是可以（或者最终可以）通过不改变现有程序的API解决掉的。因为这些原因，kqueue不是”自动检测“的，除非你特意指定这个flags（例如使用EVBACKEND_KQUEUE)或者libev在一个像NetBSD这样已知将不会出现问题的系统中编译。

You still can embed kqueue into a normal poll or select backend and use it only for sockets (after having made sure that sockets work with kqueue on the target platform). See ev_embed watchers for more info.
你仍旧可以把kqueue嵌入到一个正常的poll或者select的后台，并且只用它来处理sockets（请先确认sockets是否使用kqueue运行在目标平台上）。请查阅ev_embed watchers得到更多的信息。

It scales in the same way as the epoll backend, but the interface to the kernel is more efficient (which says nothing about its actual speed, of course). While stopping, setting and starting an I/O watcher does never cause an extra system call as with EVBACKEND_EPOLL, it still adds up to two event changes per incident. Support for fork () is very bad (you might have to leak fd's on fork, but it's more sane than epoll) and it drops fds silently in similarly hard-to-detect cases.
kqueue的伸缩性和epoll后台是一样的，但接口调用kernel的效率更高（当然，这没有实际的速度）。和epoll相比，当停止、设置和开始一个IO watcher时也不会引起额外的系统调用。它仍然每个事件变动增加2个event变动。支持fork（）是非常糟糕的（你可能会在fork时有fd泄漏，但是它比epoll少很多），他会在难以检测的情况下悄无声息的泄露fds。

This backend usually performs well under most conditions.
这个后台在多数情况下表现良好。

While nominally embeddable in other event loops, this doesn't work everywhere, so you might need to test for this. And since it is broken almost everywhere, you should only use it when you have a lot of sockets (for which it usually works), by embedding it into another event loop (e.g. EVBACKEND_SELECT or EVBACKEND_POLL (but poll is of course also broken on OS X)) and, did I mention it, using it only for sockets.
当名义上将kqueue嵌入到别的event loop时，它都是不能正常运行的，所以你必须要检测它。而且你由于它几乎无处不能运行，你只能在有很多sockets的情况下通过嵌入到另外一个event loop（例如：EVBACKEND_SELECT or EVBACKEND_POLL，当然在OS X上poll也是有问题的。）使用它（这也是它经常做的）。当我提到它的时候，它通常只被sockets使用。

This backend maps EV_READ into an EVFILT_READ kevent with NOTE_EOF, and EV_WRITE into an EVFILT_WRITE kevent with NOTE_EOF.
这个后台映射EV_READ到一个带有NOTE_EOF的EVFILT_READ，EV_WRITE映射到带有NOTE_EOF的EVFILT_WRITE。

EVBACKEND_DEVPOLL (value 16, Solaris 8)
This is not implemented yet (and might never be, unless you send me an implementation). According to reports, /dev/poll only supports sockets and is not embeddable, which would limit the usefulness of this backend immensely.
这尚未实现 （可能永远不会实现，除非你给我一个实现）。据报道，/dev/poll 只支持套接字并且不能被嵌入，这将极大的限制这个后台的用处。

EVBACKEND_PORT (value 32, Solaris 10)
This uses the Solaris 10 event port mechanism. As with everything on Solaris, it's really slow, but it still scales very well (O(active_fds)).
EVBACKEND_PORT使用solaris 10的event port机制。和一切基于solairs一样，它非常慢，但是它的扩展性非常好（O（active_fds））。

While this backend scales well, it requires one system call per active file descriptor per loop iteration. For small and medium numbers of file descriptors a "slow" EVBACKEND_SELECT or EVBACKEND_POLL backend might perform better.
虽然它的扩展性很好，但是每次迭代每个活动的文件描述符都需要一次系统调用。对于中小数量的文件描述符，一个慢的EVBACKEND_SELECT或者EVBACKEND_POLL后台可能表现更好。

On the positive side, this backend actually performed fully to specification in all tests and is fully embeddable, which is a rare feat among the OS-specific backends (I vastly prefer correctness over speed hacks).
积极的一面，这个后台实际执行完全符合所有测试的规定，并且完全嵌入。这是操作系统特定的后台之间的一个罕见的壮举（我大大喜欢正确性超过执行速度）。 

On the negative side, the interface is bizarre - so bizarre that even sun itself gets it wrong in their code examples: The event polling function sometimes returns events to the caller even though an error occurred, but with no indication whether it has done so or not (yes, it's even documented that way) - deadly for edge-triggered interfaces where you absolutely have to know whether an event occurred or not because you have to re-arm the watcher.
消极的一面，接口非常奇怪-如此的离奇以至于即使是sun它自己也写了错误的示例程序：事件轮询功能有时返回的事件给调用者，即使发生错误，但没有迹象表明它是否已经这样做了，或不（是的，它甚至记录了这样） - 致命的边沿触发接口，你绝对必须知道是否有事件发生与否，因为你必须重新设置的watcher。 

Fortunately libev seems to be able to work around these idiocies.
幸运的libev似乎能够解决这些白痴行为。

This backend maps EV_READ and EV_WRITE in the same way as EVBACKEND_POLL.
这个后端映射EV_READ和EV_WRITE到相同的方式EVBACKEND_POLL。

EVBACKEND_ALL
Try all backends (even potentially broken ones that wouldn't be tried with EVFLAG_AUTO). Since this is a mask, you can do stuff such as EVBACKEND_ALL & ~EVBACKEND_KQUEUE.
尝试所有的后台（甚至可能是那些经过EVFLAG_AUTO尝试而被拒绝的）。由于这是一个mark，你可以设置成EVBACKEND_ALL & ~EVBACKEND_KQUEUE.


It is definitely not recommended to use this flag, use whatever ev_recommended_backends () returns, or simply do not specify a backend at all.
这是一个绝对不建议使用的标志位。应该使用ev_recommended_backends（）的返回值或者干脆不指定后台。

EVBACKEND_MASK
Not a backend at all, but a mask to select all backend bits from a flags value, in case you want to mask out any backends from a flags value (e.g. when modifying the LIBEV_FLAGS environment variable).
这不是一个后台，但是是一个mask从一个flags值中选择所有的后台位，如果你想从flags值中屏蔽掉所有的后台（例如：修改LIBEV_FLAGS环境变量）。

If one or more of the backend flags are or'ed into the flags value, then only these backends will be tried (in the reverse order as listed here). If none are specified, all backends in ev_recommended_backends () will be tried.
如果一个后端或多个标志逻辑或运算压入标志值，那么只有这些后台将尝试（如在这里列出的顺序相反）。如果没有指定，在ev_recommended_backends所有的后台（）将被尝试。 

Example: Try to create a event loop that uses epoll and nothing else.
例如：尝试使用epoll来创建一个event loop。
struct ev_loop *epoller = ev_loop_new (EVBACKEND_EPOLL | EVFLAG_NOENV);
if (!epoller)
fatal ("no epoll found here, maybe it hides under your chair");

Example: Use whatever libev has to offer, but make sure that kqueue is used if available.
例如：使用任何libev所提供的后端，但要确保kqueue的使用（如果可用）

struct ev_loop *loop = ev_loop_new (ev_recommended_backends () | EVBACKEND_KQUEUE);

ev_loop_destroy (loop)
Destroys an event loop object (frees all memory and kernel state etc.). None of the active event watchers will be stopped in the normal sense, so e.g. ev_is_active might still return true. It is your responsibility to either stop all watchers cleanly yourself before calling this function, or cope with the fact afterwards (which is usually the easiest thing, you can just ignore the watchers and/or free () them for example).
释放一个event loop对象（释放所有的内存和内核状态等）。通常情况下，没有任何一个活动的event watcher将会停止，所以例如ev_is_active可能仍然返回true。所以要么你在调用这个函数之前停止所有的watchers，要么在调用这个函数之后做相应的处理（通常最简单的解决方案就是忽略watchers的free（）），这是你的职责。

Note that certain global state, such as signal state (and installed signal handlers), will not be freed by this function, and related watchers (such as signal and child watchers) would need to be stopped manually.
注意：某些全局变量，比如信号量状态（并且已经注册了信号处理函数的），将不会被这个函数释放掉，这些相关的watchers将需要你手工的停止掉（比如信号和child的watchers）。

This function is normally used on loop objects allocated by ev_loop_new, but it can also be used on the default loop returned by ev_default_loop, in which case it is not thread-safe.
这个函数经常被用来释放由ev_loop_new函数分配的event loop对象。但是它也可以被用来释放由ev_default_loop函数分配的默认event loop对象。当然，这样的话，它就不是线程安全的。

Note that it is not advisable to call this function on the default loop except in the rare occasion where you really need to free its resources. If you need dynamically allocated loops it is better to use ev_loop_new and ev_loop_destroy.
注意：在默认的loop上调用这个函数是不被推荐的，除非在极少数情况下我们真的需要释放它的资源。如果你想要动态的分配loops，调用ev_loop_new和ev_loop_destroy会更好。

ev_loop_fork (loop)
This function sets a flag that causes subsequent ev_run iterations to reinitialise the kernel state for backends that have one. Despite the name, you can call it anytime you are allowed to start or stop watchers (except inside an ev_prepare callback), but it makes most sense after forking, in the child process. You must call it (or use EVFLAG_FORKCHECK) in the child before resuming or calling ev_run.
这个函数设置一个标志来使后续rv_run迭代重新初始化内核状态（应该是event loop的状态吧？）来得到一个后台。（这句不太有把握，但是应该是这样的）。不用理会这个函数的名字，其实你可以在任何你被允许开始或者停止watchers的时候（除了在一个ev_prepare回调中）调用它，但是它最大的意义在于调用创建子进程之后，在子进程中，你必须在恢复和调用ev_run之前调用它（或者使用EVFLAG_FORKCHECK）。

Again, you have to call it on any loop that you want to re-use after a fork, even if you do not plan to use the loop in the parent. This is because some kernel interfaces *cough* kqueue *cough* do funny things during fork.
即使你不想在父进程中使用这个loop，你也同样需要在fork之后为了重新使用这个loop而调用这个函数。这是因为一些内核接口在fork之中会做一些事情（ *cough* kqueue *cough*  这是嘛意思？其实这个句话就是在fork的时候会改变libev的loop，所以需要重新设置）。

On the other hand, you only need to call this function in the child process if and only if you want to use the event loop in the child. If you just fork+exec or create a new loop in the child, you don't have to call it at all (in fact, epoll is so badly broken that it makes a difference, but libev will usually detect this case on its own and do a costly reset of the backend).
另一方面，假如你仅仅想在子进程中使用这个event loop，你只要在子进程中调用这个函数。如果你只是使用fork+exec的方式或者是在子进程中创建一个新的loop，那么你不需要调用这个函数。（事实上，epoll是如此的糟糕以至于是如此的与众不同，但是libev通常会自己监测到这种情况并且对这个后台做代价昂贵的复位）。

The function itself is quite fast and it's usually not a problem to call it just in case after a fork.
这个函数是非常快的，在fork之后调用它通常不是一个问题。

Example: Automate calling ev_loop_fork on the default loop when using pthreads.
示例：当使用pthreads时，默认的loop自动调用ev_loop_fork

static void
post_fork_child (void)
{
ev_loop_fork (EV_DEFAULT);
}

...
pthread_atfork (0, 0, post_fork_child);

int ev_is_default_loop (loop)
Returns true when the given loop is, in fact, the default loop, and false otherwise.
当给定的loop事实上是默认的loop时返回true，否则返回false。

unsigned int ev_iteration (loop)
Returns the current iteration count for the event loop, which is identical to the number of times libev did poll for new events. It starts at 0 and happily wraps around with enough iterations.
返回当前event loop的迭代次数，它和libev为了新的events做poll的次数是相同的。它从0开始并且包含有足够的迭代。

This value can sometimes be useful as a generation counter of sorts (it "ticks" the number of loop iterations), as it roughly corresponds with ev_prepare and ev_check calls - and is incremented between the prepare and check phases.
这个值作为各种各样的一代计数器时可能会非常有用（它驱动loop的迭代次数），因为它大致和ev_prepare和ev_check的调用次数相同，并且它在prepare和check的中间阶段递增。

unsigned int ev_depth (loop)
Returns the number of times ev_run was entered minus the number of times ev_run was exited normally, in other words, the recursion depth.
返回ev_run进入的次数减去ev_run正常退出的次数，换句话说，是递归的深度。

Outside ev_run, this number is zero. In a callback, this number is 1, unless ev_run was invoked recursively (or from another thread), in which case it is higher.
在ev_run范围之外，这个值是0，在一个回调中，这个值是1，除非ev_run被递归的调用（或者从另外一个线程调用），在这种情况下，这个值会更高。

Leaving ev_run abnormally (setjmp/longjmp, cancelling the thread, throwing an exception etc.), doesn't count as "exit" - consider this as a hint to avoid such ungentleman-like behaviour unless it's really convenient, in which case it is fully supported.
异常的退出ev_run（setjmp/longjmp，取消这个线程，抛出一个异常等等）不能算作是正常退出。把它看成一个避免类似的下三滥行为的提示，除非它真的很方便，在这种情况下，它是被支持的。

unsigned int ev_backend (loop)
Returns one of the EVBACKEND_* flags indicating the event backend in use.
返回EVBACKEND_*之一，说明那个event backed正在使用。

ev_tstamp ev_now (loop)
Returns the current "event loop time", which is the time the event loop received events and started processing them. This timestamp does not change as long as callbacks are being processed, and this is also the base time used for relative timers. You can treat it as the timestamp of the event occurring (or more correctly, libev finding out about it).
返回当前“event loop”的时间，它是接收到事件并且开始处理它们的时间。在回调被处理的时候，这个时间戳不会被改变，并且这也是用于相对定时器的基准时间。你可以把它看成事件发生的时间戳（或者更正确的说，libev找不到它）（译者注：最后一句libev找不到它什么意思？）

ev_now_update (loop)
Establishes the current time by querying the kernel, updating the time returned by ev_now () in the progress. This is a costly operation and is usually done automatically within ev_run ().
通过查询内核，更新进程中由ev_now()返回的当前时间。这个操作很昂贵，并且这个操作一般都是由ev_run自动实现。

This function is rarely useful, but when some event callback runs for a very long time without entering the event loop, updating libev's idea of the current time is a good idea.
这个函数很少有用，但是当一些event的回调运行很长时间并且没有进入event loop时，更新libev的当前时间是一个好主意。

See also The special problem of time updates in the ev_timer section.
请参阅ev_timer部分更新时间的特别问题。

ev_suspend (loop)
ev_resume (loop)
These two functions suspend and resume an event loop, for use when the loop is not used for a while and timeouts should not be processed.
这2个函数暂停和恢复一个event loop。当loop已经很长时间没被使用的时候，不用处理过期时间。

A typical use case would be an interactive program such as a game: When the user presses ^Z to suspend the game and resumes it an hour later it would be best to handle timeouts as if no time had actually passed while the program was suspended. This can be achieved by calling ev_suspend in your SIGTSTP handler, sending yourself a SIGSTOP and calling ev_resume directly afterwards to resume timer processing.
一个典型的使用场景是一个交互程序，例如游戏：当用处按下 ^Z来暂停游戏并且在一个小时后候恢复，那么最好处理过期时间，就像在程序暂停的时候真正的时间没有过去一样。这可以通过在SIGTSTP信号处理函数中调用ev_suspend，给自己发送SIGSTOP信号并且调用ev_resume直接事后恢复定时器处理来实现。 

Effectively, all ev_timer watchers will be delayed by the time spend between ev_suspend and ev_resume, and all ev_periodic watchers will be rescheduled (that is, they will lose any events that would have occurred while suspended).
事实上，所有的ev_timer都会被通过在ev_suspend和ev_resume之间花费时间而被延迟，而所有的ev_periodic watchers将会被重新安排（即，他们将会丢失掉一些在暂停的时候已经发生的事件）。

After calling ev_suspend you must not call any function on the given loop other than ev_resume, and you must not call ev_resume without a previous call to ev_suspend.
在调用ev_suspend之后，你不能在这个loop上调用除了ev_resume之外的函数，并且你不能在没有调用ev_suspend之前调用ev_resume。

Calling ev_suspend/ev_resume has the side effect of updating the event loop time (see ev_now_update).
调用ev_suspend/ev_resume将会对更新event loop时间有副作用.(请查看ev_now_update）。

bool ev_run (loop, int flags)
Finally, this is it, the event handler. This function usually is called after you have initialised all your watchers and you want to start handling events. It will ask the operating system for any new events, call the watcher callbacks, and then repeat the whole process indefinitely: This is why event loops are called loops.
最后，这就是事件处理程序。这个函数通常在你已经初始化你所有的watchers和你想开始处理events时调用。它将会询问操作系统任何新的events，调用watcher的回调函数，并且无限制的重复整个过程：这就是为什么event loop被称作循环。

If the flags argument is specified as 0, it will keep handling events until either no event watchers are active anymore or ev_break was called.
如果标志位参数被设置成0，他将会继续处理事件，直到没有活跃的event watchers或者ev_break被调用。

The return value is false if there are no more active watchers (which usually means "all jobs done" or "deadlock"), and true in all other cases (which usually means " you should call ev_run again”).
如果没有更多的活跃watchers（通常意味着所有的工作都完成了或者是死锁了）将会返回false，在其他情况下返回true（这通常意味着你需要再一次调用ev_run）。

Please note that an explicit ev_break is usually better than relying on all watchers to be stopped when deciding when a program has finished (especially in interactive programs), but having a program that automatically loops as long as it has to and no longer by virtue of relying on its watchers stopping correctly, that is truly a thing of beauty.
请注意：一个明确的ev_break调用要好于依赖所有的watchers被停止来决定完成一个程序（特别是交互式程序）。有一些程序只要它必须并且仍然相信所有的watcers可以正确的停止。这才是真正美妙的事情。（译者注：这句话就是可能真正美好的程序就是event loop自动的可以依靠event全部完成而自行结束？）。

This function is mostly exception-safe - you can break out of a ev_run call by calling longjmp in a callback, throwing a C++ exception and so on. This does not decrement the ev_depth value, nor will it clear any outstanding EVBREAK_ONE breaks.
这个函数主要是“异常安全”的，你可以通过在回调中调用longjmp，抛出一个cxx的异常或者等等方法来跳出ev_run，这不会减少ev_depth的值，也不会清除任何没有解决的EVBREAK_ONE.

A flags value of EVRUN_NOWAIT will look for new events, will handle those events and any already outstanding ones, but will not wait and block your process in case there are no events and will return after one iteration of the loop. This is sometimes useful to poll and handle new events while doing lengthy calculations, to keep the program responsive.
EVRUN_NOWAIT这个标志值将会寻找新的事件，并且处理这些事件和那些已经未解决的事件，但是在没有事件的情况下，它不会等待并且阻塞你的进程，并且在一次loop迭代后返回。这个标志值在poll和处理新事件时需要长时间计算来保持程序相应的时候通常是有用的。

A flags value of EVRUN_ONCE will look for new events (waiting if necessary) and will handle those and any already outstanding ones. It will block your process until at least one new event arrives (which could be an event internal to libev itself, so there is no guarantee that a user-registered callback will be called), and will return after one iteration of the loop.
EVRUN_ONCE这个标志值将会寻找新的时间（如果有必要将会等待新的事件），并且处理这些事件和那些已经未解决的事件，它将会阻塞你的进程直到至少一个新的事件到达（这个事件可能是libev自己的内部事件，所以不能保证用户注册的回调将会被调用），并且在一次loop迭代后返回；

This is useful if you are waiting for some external event in conjunction with something not expressible using other libev watchers (i.e. "roll your own ev_run"). However, a pair of ev_prepare/ev_check watchers is usually a better approach for this kind of thing.
如果你正在等待外部事件并且并没有使用另外的libev watcher，这是非常有用的（例如：循环你自己的ev_run)，但是，一对ev_prepare/ev_check watchers通常是这种事情更好的方法。

Here are the gory details of what ev_run does (this is for your understanding, not a guarantee that things will work exactly like this in future versions):
这是吐血推荐的ev_run的细节（这是给你理解用的，并不能保证在将来的版本中也会这样运行）。

   - Increment loop depth.
       增加loop的深度（是不是循环次数？）
   - Reset the ev_break status.
       重置ev_break的状态
   - Before the first iteration, call any pending watchers.
       在首次循环之前，调用pending watchers。
       LOOP:
   - If EVFLAG_FORKCHECK was used, check for a fork.
       如果EVFLAG_FORKCHECK被使用，检查fork。
   - If a fork was detected (by any means), queue and call all fork watchers.
       如果fork被检测到（不管使用任何方法），排队并且调用所有的fork watchers。
   - Queue and call all prepare watchers.
       排队并且调用所有的前期准备watchers。
   - If ev_break was called, goto FINISH.
       如果ev_break被调用，直接运行FINISH。
   - If we have been forked, detach and recreate the kernel state
       如果fork被调用，分离并且重新创建内核状态，来达到不干扰其他进程的目的。
       as to not disturb the other process.
   - Update the kernel state with all outstanding changes.
       使用未完成的改变来更新内核状态。
   - Update the "event loop time" (ev_now ()).
       更新event loop时间（ev_now（））。
   - Calculate for how long to sleep or block, if at all
       休眠或者究竟阻塞了多长时间，（主动闲置的watchers，EVRUN_NOWAIT或者没有任何活动的watchers导致不会睡眠。）（PS：这句话很别扭）。
       (active idle watchers, EVRUN_NOWAIT or not having
       any active watchers at all will result in not sleeping).
   - Sleep if the I/O and timer collect interval say so.
       在IO和timer的时间间隔区休眠
   - Increment loop iteration counter.
       增加循环迭代计数
   - Block the process, waiting for any events.
       阻塞进程，等待任何events
   - Queue all outstanding I/O (fd) events.
       排队所有未完成的IO事件（fd）
   - Update the "event loop time" (ev_now ()), and do time jump adjustments.
         - 更新“事件循环时间”（ev_now（）），并做一次大的调整。
   - Queue all expired timers.
       队列中的所有过期的计时器
   - Queue all expired periodics.
       队列中的所有过期periodics。 
   - Queue all idle watchers with priority higher than that of pending events.
       队列中的所有空闲的watchers优先级高于挂起事件。
   - Queue all check watchers.
       排队所有check watchers。
   - Call all queued watchers in reverse order (i.e. check watchers first).
       以倒序调用所有排列后的watchers（例如，首先是check watchers）。
       Signals and child watchers are implemented as I/O watchers, and will
       be handled here by queueing them when their watcher gets executed.
       信号和子程序 watchers被当作io watchers实现，并且当他们的watchers被执行时会被在这里排序处理。
   - If ev_break has been called, or EVRUN_ONCE or EVRUN_NOWAIT
       were used, or there are no active watchers, goto FINISH, otherwise
       continue with step LOOP.
       如果ev_break被调用，或者EVRUN_ONCE或者EVRUN_NOWAIT被使用，或者没有活动的watchers，直接运行FINISH；否则继续loop步骤。
       FINISH:
   - Reset the ev_break status iff it was EVBREAK_ONE.
       当且仅当它是EVBREAK_ONE时，充值EV_BREAK
   - Decrement the loop depth.
       减少loop的层次
   - Return.
       返回

       Example: Queue some jobs and then loop until no events are outstanding anymore.
       排列一些jobs，然后循环直到没有事件被凸显出来。

       ... queue jobs here, make sure they register event watchers as long
       ... as they still have work to do (even an idle watcher will do..)
       ev_run (my_loop, 0);
       ... jobs done or somebody called break. yeah!

       ev_break (loop, how)
       Can be used to make a call to ev_run return early (but only after it has processed all outstanding events). The how argument must be either EVBREAK_ONE, which will make the innermost ev_run call return, or EVBREAK_ALL, which will make all nested ev_run calls return.
       调用此函数让ev_run结束并且返回（但是必须在处理完未决的事件）。how参数可能是EVBREAK_ONE，这将使ev_run最里面的循环返回，或者是EVBREAK_ALL，这将使得所有的循环嵌套返回。

       This "break state" will be cleared on the next call to ev_run.
       这种break状态将会在ev_run的下一次调用中清除。

       It is safe to call ev_break from outside any ev_run calls, too, in which case it will have no effect.
       在ev_run调用之外调用ev_break是安全的，在这种情况下，调用将没有任何效果。

       ev_ref (loop)
       ev_unref (loop)
       Ref/unref can be used to add or remove a reference count on the event loop: Every watcher keeps one reference, and as long as the reference count is nonzero, ev_run will not return on its own.
       ref/unref被用来增加或者删除一个event loop的引用计数，每一个watcher都保存了一个引用，只要引用计数不为零，ev_run就不会自行返回。

       This is useful when you have a watcher that you never intend to unregister, but that nevertheless should not keep ev_run from returning. In such a case, call ev_unref after starting, and ev_ref before stopping it.
       当你有一个从来没有打算注销的watcher，但仍然不想让ev_run无法返回的时候，这是非常有用的。在这种情况下，你可以在开始之后调用ev_unref和在停止之前调用ev_ref。

       As an example, libev itself uses this for its internal signal pipe: It is not visible to the libev user and should not keep ev_run from exiting if no event watchers registered by it are active. It is also an excellent way to do this for generic recurring timers or from within third-party libraries. Just remember to unref after start and ref before stop (but only if the watcher wasn't active before, or was active before, respectively. Note also that libev might stop watchers itself (e.g. non-repeating timers) in which case you have to ev_ref in the callback).
       作为一个例子，libev自己内部使用这些函数来处理signal pipe（这里是不是翻译成SIGPIPE这个信号啊？），它对于最终的libev用户来说是不可见的，并且如果没有event watchers被注册成活跃的，它不应该让ev_run退出。对于一般性的定时器和第三方的程序库，这也是一个很好的方法。只需要记住在开始的时候unref，并且在stop之前ref（但是仅当分别在watcher不活跃之前，或者已经活跃之前）也要注意在某些你需要在回调中ev_ref的情况下，libev将会自己停止watchers（例如：不重复的定时器）。

       Example: Create a signal watcher, but keep it from keeping ev_run running when nothing else is active.
       示例：创建一个信号watcher，并且保证它在没有任何另外活跃的事件的时候，保持ev_run运行。

       ev_signal exitsig;
       ev_signal_init (&exitsig, sig_cb, SIGINT);
       ev_signal_start (loop, &exitsig);
       ev_unref (loop);

       Example: For some weird reason, unregister the above signal handler again.
       例如：对于一些奇怪的原因，再注销上面的信号事件处理程序。

       ev_ref (loop);
       ev_signal_stop (loop, &exitsig);

       ev_set_io_collect_interval (loop, ev_tstamp interval)
       ev_set_timeout_collect_interval (loop, ev_tstamp interval)
       These advanced functions influence the time that libev will spend waiting for events. Both time intervals are by default 0, meaning that libev will try to invoke timer/periodic callbacks and I/O callbacks with minimum latency.
       这些高级功能会影响libev将会花在等待events的时间。两者的时间间隔默认为0.意味着libev将会试着以最小的延迟来调用timer/periodic的回调和io的回调。

       Setting these to a higher value (the interval must be >= 0) allows libev to delay invocation of I/O and timer/periodic callbacks to increase efficiency of loop iterations (or to increase power-saving opportunities).
       把这些值设置的大一点（时间间隔必须大于0）将会允许libev延迟调用io和timer、peroodic的回调函数，来增加loop循环调用的效率（或者增加省电的机会）。

       The idea is that sometimes your program runs just fast enough to handle one (or very few) event(s) per loop iteration. While this makes the program responsive, it also wastes a lot of CPU time to poll for new events, especially with backends like select () which have a high overhead for the actual polling but can deliver many events at once.
       libev的假设是有的时候，你的程序将会运行的很快，快到足够每次循环来处理一个事件（或者很少的事件），虽然这样可以让程序保持了高响应，但是也浪费了很多的CPU时间来轮训新的事件，特别是当后台使用像select（）这种需要高系统开销的实际的轮流检测，但是可以立刻发现很多事件。

       By setting a higher io collect interval you allow libev to spend more time collecting I/O events, so you can handle more events per iteration, at the cost of increasing latency. Timeouts (both ev_periodic and ev_timer) will not be affected. Setting this to a non-null value will introduce an additional ev_sleep () call into most loop iterations. The sleep time ensures that libev will not poll for I/O events more often then once per this interval, on average (as long as the host time resolution is good enough).
       通过设置一个较高的io collect时间间隔，你将会允许libev花更多的时间来发现IO事件，所以你可以通过增加延迟的成本来一次迭代处理多个事件。时间过期（包括ev_periodic和ev_timer）将不会受到影响。设置这个值为“非空”，将会在大多数的loop迭代中增加一个ev_sleep调用。休眠时间确保libev将不会多余每次的时间间隔来循环触发IO事件。

       Likewise, by setting a higher timeout collect interval you allow libev to spend more time collecting timeouts, at the expense of increased latency/jitter/inexactness (the watcher callback will be called later). ev_io watchers will not be affected. Setting this to a non-null value will not introduce any overhead in libev.
       同样，通过设置一个较高的超时时间间隔，你将会允许libev花很多的时间来触发超时，这将会增加延迟/抖动/不精确（watchers的回调将在后面调用）的开销。ev_io watchers将不会收到影响。将其设置为一个“非空”值将不会增加libev任何的开销。

       Many (busy) programs can usually benefit by setting the I/O collect interval to a value near 0.1 or so, which is often enough for interactive servers (of course not for games), likewise for timeouts. It usually doesn't make much sense to set it to a lower value than 0.01, as this approaches the timing granularity of most systems. Note that if you do transactions with the outside world and you can't increase the parallelity, then this setting will limit your transaction rate (if you need to poll once per transaction and the I/O collect interval is 0.01, then you can't do more than 100 transactions per second).
       很多（繁忙）的程序通常可以通过设置IO触发间隔为0.1左右来受益（效率最大化嘛？）同样的超时时间经常满足一些交互式服务器（当然不能满足游戏。PS：游戏设置多好合适？，貌似没说）。通常，将其设置为一个小于0.01的数将会失去意义，因为0.01通常是大多数系统的时间精度。注意：如果你这样和外界的接口通讯，那么你将不能增加程序的并行性，则这样的设置将会限制你的成功率（如果你需要轮训每次事务，并且IO collect 时间间隔是0.01.你最大的吞吐量也就是100/s）。

       Setting the timeout collect interval can improve the opportunity for saving power, as the program will "bundle" timer callback invocations that are "near" in time together, by delaying some, thus reducing the number of times the process sleeps and wakes up again. Another useful technique to reduce iterations/wake-ups is to use ev_periodic watchers and make sure they fire on, say, one-second boundaries only.
       设置这个超时时间间隔将会改善省电的机会（PS：效率变慢了？），程序将会捆绑的调用那些超时时间接近的回调函数，通过一些延迟，减少了进程休眠的次数和唤醒的次数，另外一个有用的技术是在使用ev_periodic watchers的时候减少迭代和唤醒的次数，并且确保他们被触发，也就是说，只有一秒钟的时间间隔。（PS：最后一个一秒的界限是什么意思？）

       Example: we only need 0.1s timeout granularity, and we wish not to poll more often than 100 times per second:
       示例：我们仅仅需要0.1s的超时精度，并且我们希望迭代少于100次/s。

       ev_set_timeout_collect_interval (EV_DEFAULT_UC_ 0.1);
       ev_set_io_collect_interval (EV_DEFAULT_UC_ 0.01);

       ev_invoke_pending (loop)
       This call will simply invoke all pending watchers while resetting their pending state. Normally, ev_run does this automatically when required, but when overriding the invoke callback this call comes handy. This function can be invoked from a watcher - this can be useful for example when you want to do some lengthy calculation and want to pass further event handling to another thread (you still have to make sure only one thread executes within ev_invoke_pending or ev_run of course).
       这个调用将会简单的调用所有未触发的watchers并且重置它们的未触发状态。通常，ev_run在需要的情况下自动的做这些，但是当覆盖这个回调调用的时候，ev_invoke_pending将会变得得心应手。这个函数将可以在一个watcher中被调用，例如对于你想做一些耗时的计算并且希望另外一个线程进一步的处理来说将会是非常有用的。（当然，你仍然必须保证只有一个线程执行e_invoke_pending或者ev_run）。

       int ev_pending_count (loop)
       Returns the number of pending watchers - zero indicates that no watchers are pending.
       返回未被触发的watchers数目-0表示没有未触发的watchers。

       ev_set_invoke_pending_cb (loop, void (*invoke_pending_cb)(EV_P))
       This overrides the invoke pending functionality of the loop: Instead of invoking all pending watchers when there are any, ev_run will call this callback instead. This is useful, for example, when you want to invoke the actual watchers inside another context (another thread etc.).
       这将重写loop的调用未触发函数：当它存在的时候，将会代替调用所有的未触发watchers，ev_run将会调用这个回调替代。例如对于你想调用真实的watchers在另外一个上下文环境中（另外一个线程等等）将会是非常有用的。

       If you want to reset the callback, use ev_invoke_pending as new callback.
       如果你想重置这个回调，使用ev_invoke_penging作为新的回调。

       ev_set_loop_release_cb (loop, void (*release)(EV_P) throw (), void (*acquire)(EV_P) throw ())
       Sometimes you want to share the same loop between multiple threads. This can be done relatively simply by putting mutex_lock/unlock calls around each call to a libev function.
       有时你想在多个线程中共享同一个loop。这将可以通过在libev的函数中放置mutex的lock/unlock来简单的实现。

       However, ev_run can run an indefinite time, so it is not feasible to wait for it to return. One way around this is to wake up the event loop via ev_break and ev_async_send, another way is to set these release and acquire callbacks on the loop.
       然而，ev_run是在一个不确定的时间运行的，所以要等待它返回是不可行的。一种解决办法就是通过ev_break和ev_async_send来唤醒event loop，另外一种解决方法就是在循环的时候设置Release和acquire回调。

       When set, then release will be called just before the thread is suspended waiting for new events, and acquire is called just afterwards.
       当设置Release和acquire的时候，Release将会在线程被挂起等待新事件之前被调用，acquire将会在等到新事件后被调用。

       Ideally, release will just call your mutex_unlock function, and acquire will just call the mutex_lock function again.
       理想情况下，Release将会只调用你的mutex的unlock函数，而acquire将只调用mutex的lock函数。

       While event loop modifications are allowed between invocations of release and acquire (that's their only purpose after all), no modifications done will affect the event loop, i.e. adding watchers will have no effect on the set of file descriptors being watched, or the time waited. Use an ev_async watcher to wake up ev_run when you want it to take note of any changes you made.
       在Release和acquire调用之间修改event loop是被允许的（毕竟这是它们唯一的目的），没有修改完成将会影响event loop，例如：加入的那些watchers 在那些被监视的文件描述符或者时间等待上没有效果。当你想注意那些你制造的任何更改时，使用ev_async watcher来唤醒ev_run。

       In theory, threads executing ev_run will be async-cancel safe between invocations of release and acquire.
       理论上，在Release和acquire调用之间，线程执行ev_run将不是异步安全的。

       See also the locking example in the THREADS section later in this document.
       请参阅本文档后面在THREADS章节的有关于说的示例。

       ev_set_userdata (loop, void *data)
       void *ev_userdata (loop)
       Set and retrieve a single void * associated with a loop. When ev_set_userdata has never been called, then ev_userdata returns 0.
       设置和获取一个和loop相关联的void *（PS：译为对象可能会好一些）。当ev_set_userdata没有被调用的时候，ev_userdata将会返回0.

       These two functions can be used to associate arbitrary data with a loop, and are intended solely for the invoke_pending_cb, release and acquire callbacks described above, but of course can be (ab-)used for any other purpose as well.
       这两个函数用来和loop关联任何数据，并且仅仅在invoke_pending_cb，Release和acquire回调之中可以被获取，但是当然也可以被用于其他目的。

       ev_verify (loop)
       This function only does something when EV_VERIFY support has been compiled in, which is the default for non-minimal builds. It tries to go through all internal structures and checks them for validity. If anything is found to be inconsistent, it will print an error message to standard error and call abort ().
       当EV_VERIFY被开启并且被编译的时候，这个函数才会有作用，这是默认的非最小版本（PS：不明白什么意思），它试图检查所有的内部结构体和检查他们的有效性。如果发现任何的不一致，它将会打印一个错误的消息并且调用abort终止程序。

       This can be used to catch bugs inside libev itself: under normal circumstances, this function will never abort as of course libev keeps its data structures consistent.
       这可以被用来捕捉内部libev本身的错误：在正常情况下，当libev保持它的数据结构是一致的时候，这个函数将永远不会abort。

       ANATOMY OF A WATCHER
       watcher的详细说明

       In the following description, uppercase TYPE in names stands for the watcher type, e.g. ev_TYPE_start can mean ev_timer_start for timer watchers and ev_io_start for I/O watchers.
       在下面的描述中，名称中大写的TYPE表示watcher的类型。例如ev_TYPE_start可以表示用于定时器的ev_timer_start，也可以表示用于IO watchers的ev_io_start。

       A watcher is an opaque structure that you allocate and register to record your interest in some event. To make a concrete example, imagine you want to wait for STDIN to become readable, you would create an ev_io watcher for that:
       watcher是一个你创建并且注册到你感兴趣的event的不透明的结构体，举个具体的例子，假设你想要等到你的STDIN变得可读，你将创建如下的一个watcher：

       static void my_cb (struct ev_loop *loop, ev_io *w, int revents)
       {
       ev_io_stop (w);
       ev_break (loop, EVBREAK_ALL);
       }

       struct ev_loop *loop = ev_default_loop (0);

       ev_io stdin_watcher;

       ev_init (&stdin_watcher, my_cb);
       ev_io_set (&stdin_watcher, STDIN_FILENO, EV_READ);
       ev_io_start (loop, &stdin_watcher);

       ev_run (loop, 0);

       As you can see, you are responsible for allocating the memory for your watcher structures (and it is usually a bad idea to do this on the stack).
       就像你看到的，你有职责为你的watcher分配内存（通常的，使用栈内存是一个不明智的主意）。（译者注：作者的意思是你应该尽量使用堆内存）

       Each watcher has an associated watcher structure (called struct ev_TYPE or simply ev_TYPE, as typedefs are provided for all watcher structs).
       每一个watcher都有相关联的结构体（称为struct ev_TYPE或者干脆使用ev_TYPE作为所有watcher的结构体定义）。

       Each watcher structure must be initialised by a call to ev_init (watcher *, callback), which expects a callback to be provided. This callback is invoked each time the event occurs (or, in the case of I/O watchers, each time the event loop detects that the file descriptor given is readable and/or writable).
       每一个watcher必须提供一个回调，并且调用ev_init来初始化，这个回调将会在每次事件发生的时候被调用（或者对于IO watcher来说，event loop将会在文件描述符变得可读或者可写的情况下调用）。

       Each watcher type further has its own ev_TYPE_set (watcher *, ...) macro to configure it, with arguments specific to the watcher type. There is also a macro to combine initialisation and setting in one call: ev_TYPE_init (watcher *, callback, …).
       每一个watcher类型都拥有带有指定watcher类型参数的，它自己的ev_TYPE_set宏来配置它。这有一个组合了初始化和配置功能的宏供使用，它就是ev_TYPE_init。

       To make the watcher actually watch out for events, you have to start it with a watcher-specific start function (ev_TYPE_start (loop, watcher *)), and you can stop watching for events at any time by calling the corresponding stop function (ev_TYPE_stop (loop, watcher *).
       为了使watcher开始监视事件，你必须使用watcher专用的开始函数ev_TYPE_start来启动它，你也可以在任何时候通过调用相应的停止函数ev_TYPE_stop来停止监视事件。

       As long as your watcher is active (has been started but not stopped) you must not touch the values stored in it. Most specifically you must never reinitialise it or call its ev_TYPE_set macro.
       只要你的watcher还存活着（已经开始还没有停止），你没必要去更改它的值，最具体的，你没必要去重新初始化或者调用它的ev_TYPE_set宏。

       Each and every callback receives the event loop pointer as first, the registered watcher structure as second, and a bitset of received events as third argument.
       每一个回调函数第一个参数是event loop的指针，第二个参数是已经注册的watcher结构，第三个参数是接收到的事件标志位。

       The received events usually include a single bit per event type received (you can receive multiple events at the same time). The possible bit masks are:
       接受到的事件经常包括一个bit数据集（你可以同时接收到多个时间），这个标志位经常包括：

       EV_READ
       EV_WRITE
       The file descriptor in the ev_io watcher has become readable and/or writable.
       ev_io watcher中的文件描述符变得可读和/或者可写。

       EV_TIMER
       The ev_timer watcher has timed out.
       定时器watcher超时。

       EV_PERIODIC
       The ev_periodic watcher has timed out.
       ev_periodic watcher超时。

       EV_SIGNAL
       The signal specified in the ev_signal watcher has been received by a thread.
       线程收到一个由ev_signal watcher指定的信号。

       EV_CHILD
       The pid specified in the ev_child watcher has received a status change.
       接收到由ev_child watcher指定的pid的进程状态的改变。

       EV_STAT
       The path specified in the ev_stat watcher changed its attributes somehow.
       接收到由ev_stat watcher监视的path的属性被改变

       EV_IDLE
       The ev_idle watcher has determined that you have nothing better to do.
       ev_ide watcher确定你已经没有什么更好的事情可以做。


EV_PREPARE
EV_CHECK
All ev_prepare watchers are invoked just before ev_run starts to gather new events, and all ev_check watchers are queued (not invoked) just after ev_run has gathered them, but before it queues any callbacks for any received events. That means ev_prepare watchers are the last watchers invoked before the event loop sleeps or polls for new events, and ev_check watchers will be invoked before any other watchers of the same or lower priority within an event loop iteration.
所有的ev_prepare watcher将会在ev_run开始收集新事件之前被调用，所有的ev_check watchers被在ev_run收集到新事件之后排队（不调用），但是在它之前，排列任意已经接收到的事件的任何回调。这意味着ev_prepare watcher是event loop休眠或者循环监视新事件之前的最后一个watcher调用，ev_check watcher将在相同或较低优先级的事件循环迭代内的任何其他watcher之前被调用。

Callbacks of both watcher types can start and stop as many watchers as they want, and all of them will be taken into account (for example, a ev_prepare watcher might start an idle watcher to keep ev_run from blocking).
两个watcher类型的回调函数都可以启动和停止他们想要的watchers，所有的watcher都将被考虑在内（例如，一个ev_prepare watcher可以启动一个idle watcher来保持ev_run阻塞）。

EV_EMBED
The embedded event loop specified in the ev_embed watcher needs attention.
在ev_embed watcher中指定植入的event loop需要注意的时候。

EV_FORK
The event loop has been resumed in the child process after fork (see ev_fork).
在fork之后的子进程中，event loop被恢复（具体查看ev_fork）。

EV_CLEANUP
The event loop is about to be destroyed (see ev_cleanup).
event loop将会被释放（具体查看ev_cleanup）。

EV_ASYNC
The given async watcher has been asynchronously notified (see ev_async).
给定的异步wacther已经被异步的通知（具体查看ev_async）。

EV_CUSTOM
Not ever sent (or otherwise used) by libev itself, but can be freely used by libev users to signal watchers (e.g. via ev_feed_event).
libev自己没有发送过（或者说使用过），但是可以自由的用于libev的信号watcher（例如，通过ev_feed_event）。

EV_ERROR
An unspecified error has occurred, the watcher has been stopped. This might happen because the watcher could not be properly started because libev ran out of memory, a file descriptor was found to be closed or any other problem. Libev considers these application bugs.
一个未指定的错误已经发生，watcher已经被停止。这个可能发生了：watcher不能正常的启动，libev耗尽内存，一个文件描述符被发现已经关闭，或者是另外的一些问题。libev认为这些是应用程序级别的bugs。

You best act on it by reporting the problem and somehow coping with the watcher being stopped. Note that well-written programs should not receive an error ever, so when your watcher receives it, this usually indicates a bug in your program.
这种问题你最好的处理艺术是报告这些问题，并且想办法应对这些watcher将要停止。注意：良好的程序是不会不断的收到错误的，所以，当你的watcher接受到这些错误的时候，经常表明在你的程序中有bug。

Libev will usually signal a few "dummy" events together with an error, for example it might indicate that a fd is readable or writable, and if your callbacks is well-written it can just attempt the operation and cope with the error from read() or write(). This will not work in multi-threaded programs, though, as the fd could already be closed and reused for another thing, so beware.
libev经常会和一些错误一起标记一些假的事件。例如，libev可能会表明一个fd已经可读或者可写了，如果你的程序写的很好，回调会只是尝试去操作，并且可以应对来自read或者write的错误。这在多线程程序中将不会正常运行，不过，鉴于这个fd已经被关闭，可以给另外一些事件重复使用，所以要小心。

GENERIC WATCHER FUNCTIONS
watcher的通用函数

ev_init (ev_TYPE *watcher, callback)
This macro initialises the generic portion of a watcher. The contents of the watcher object can be arbitrary (so malloc will do). Only the generic parts of the watcher are initialised, you need to call the type-specific ev_TYPE_set macro afterwards to initialise the type-specific parts. For each type there is also a ev_TYPE_init macro which rolls both calls into one.
这个宏将初始化watcher的通用部分。watcher对象的内容可以是任意的（所以可以使用malloc）。只有watcher的通用部分被初始化，然后你要调用指定类型的ev_TYPE_set宏来初始化特定的部分。每一个类型都有一个ev_TYPE_init宏，它可以一次调用ev_TYPE_init和ev_TYPE_set两个宏。

You can reinitialise a watcher at any time as long as it has been stopped (or never started) and there are no pending events outstanding.
只要watcher已经停止（或者从来没有启动），也没有未处理的事件，你可以在任何时候重新初始化watcher。

The callback is always of type void (*)(struct ev_loop *loop, ev_TYPE *watcher, int revents).
watcher的回调函数一直被定义成 void (*)(struct ev_loop *loop, ev_TYPE *watcher, int revents).。

Example: Initialise an ev_io watcher in two steps.
示例：两部初始化一个ev_iowatcher

ev_io w;
ev_init (&w, my_cb);
ev_io_set (&w, STDIN_FILENO, EV_READ);

ev_TYPE_set (ev_TYPE *watcher, [args])
This macro initialises the type-specific parts of a watcher. You need to call ev_init at least once before you call this macro, but you can call ev_TYPE_set any number of times. You must not, however, call this macro on a watcher that is active (it can be pending, however, which is a difference to the ev_init macro).
这个宏初始化watcher的特定部分。你在调用此宏之前必须要先至少调用一次ev_init，当然你也可以多次调用此宏。但是，你不能在这个watcher活跃的时候调用此宏（但是它可以是挂起的，这是和ev_init不一样的地方）。

Although some watcher types do not have type-specific arguments (e.g. ev_prepare) you still need to call its set macro.
尽管某些watcher类型没有特定的参数（比如ev_prepare），但是你仍然需要调用这个宏。

See ev_init, above, for an example.
示例请查看上面的ev_init部分。

ev_TYPE_init (ev_TYPE *watcher, callback, [args])
This convenience macro rolls both ev_init and ev_TYPE_set macro calls into a single call. This is the most convenient method to initialise a watcher. The same limitations apply, of course.
这是一个宏调用包括了ev_init和ev_TYPE_set的简便方法。这也是大多数程序中经常使用的方法。当然，限制是一样的。

Example: Initialise and set an ev_io watcher in one step.
示例：一步初始化并且设置一个ev_io watcher。

ev_io_init (&w, my_cb, STDIN_FILENO, EV_READ);

ev_TYPE_start (loop, ev_TYPE *watcher)
Starts (activates) the given watcher. Only active watchers will receive events. If the watcher is already active nothing will happen.
启动（或者激活）给定的watcher。只有活跃的watchers将会接收到事件。如果watcher已经是活跃的，那么什么都不会发生。

Example: Start the ev_io watcher that is being abused as example in this whole section.
示例：启动一个ev_io watcher。这是已经在整个章节中被用烂的例子。

ev_io_start (EV_DEFAULT_UC, &w);

ev_TYPE_stop (loop, ev_TYPE *watcher)
Stops the given watcher if active, and clears the pending status (whether the watcher was active or not).
如果给定的watcher是活跃的，那么停止这个watcher。并且清除挂起状态（这个watcher是否是活跃的？）。

It is possible that stopped watchers are pending - for example, non-repeating timers are being stopped when they become pending - but calling ev_TYPE_stop ensures that the watcher is neither active nor pending. If you want to free or reuse the memory used by the watcher it is therefore a good idea to always call its ev_TYPE_stop function.
停止一个行将发生的watchers将会有问题。例如，一个不重复的定时器在行将发生时将会停止，但是调用ev_TYPE_stop将确保watcher不会存活，也不会挂起。如果你想释放或者重用这个watcher的内存，那么调用ev_TYPE_stop将是一个好主意。

bool ev_is_active (ev_TYPE *watcher)
Returns a true value iff the watcher is active (i.e. it has been started and not yet been stopped). As long as a watcher is active you must not modify it.
如果返回true，那么表示watcher还是活跃的状态（例如：watcher已经被激活并且也没有被停止）。只要watcher还处于活跃状态，那么你就不能修改它。

bool ev_is_pending (ev_TYPE *watcher)
Returns a true value iff the watcher is pending, (i.e. it has outstanding events but its callback has not yet been invoked). As long as a watcher is pending (but not active) you must not call an init function on it (but ev_TYPE_set is safe), you must not change its priority, and you must make sure the watcher is available to libev (e.g. you cannot free () it).
如果返回true，那么表示watcher处于挂起状态（例如：watcher已经有事件发生，但是还没有调用事件的回调函数进行处理）。只要watcher处于挂起状态（但是不是活跃状态），你就不能调用它的init函数（但是ev_TYPE_set是安全的），你不能改变它的优先级，并且你必须保证对于libev来说，watcher是可用的（例如：你不能调用free释放这个watcher）。

callback ev_cb (ev_TYPE *watcher)
Returns the callback currently set on the watcher.
返回指定watcher设置的当前回调。

ev_set_cb (ev_TYPE *watcher, callback)
Change the callback. You can change the callback at virtually any time (modulo threads).
更改回调。你可以在任何时候无形中更改回调（modulo threads？？怎么翻译）

ev_set_priority (ev_TYPE *watcher, int priority)
int ev_priority (ev_TYPE *watcher)
Set and query the priority of the watcher. The priority is a small integer between EV_MAXPRI (default: 2) and EV_MINPRI (default: -2). Pending watchers with higher priority will be invoked before watchers with lower priority, but priority will not keep watchers from being executed (except for ev_idle watchers).
设置或者查询watcher的优先级。这个优先级是一个在EV_MAXPRI（默认是2）和EV_MINPRI（默认是-2）之间的很小的整数。挂起的高优先级watchers将会比低优先级的watchers先调用。但是优先级不能阻止watcher被执行（除了ev_idle watcher）。

If you need to suppress invocation when higher priority events are pending you need to look at ev_idle watchers, which provide this functionality.
如果你想在高优先级事件即将发生的时候抑制这个调用，你需要看一下ev_idle watcher，ev_idle watcher提供了这个功能。

You must not change the priority of a watcher as long as it is active or pending.
只要watcher是活跃的或者挂起的，你就不能更改这个watcher的优先级。

Setting a priority outside the range of EV_MINPRI to EV_MAXPRI is fine, as long as you do not mind that the priority value you query might or might not have been clamped to the valid range.
只要你不介意你查询的优先级不在有效的范围内，你把优先级设置到EV_MINPRI和EV_MAXPRI之外没有关系。

The default priority used by watchers when no priority has been set is always 0, which is supposed to not be too high and not be too low :).
当没有设置watcher的优先级的时候，默认的值一直是0.这个值不高也不低。

See WATCHER PRIORITY MODELS, below, for a more thorough treatment of priorities.
查看watcher的优先级模型，下面会有更详细的讲解。

ev_invoke (loop, ev_TYPE *watcher, int revents)
Invoke the watcher with the given loop and revents. Neither loop nor revents need to be valid as long as the watcher callback can deal with that fact, as both are simply passed through to the callback.
通过给定的loop和事件标志位来调用watcher。只要watcher的回调可以处理，既不需要循环也不需要事件有效发生。因为两者都是简单的调用回调而已。

int ev_clear_pending (loop, ev_TYPE *watcher)
If the watcher is pending, this function clears its pending status and returns its revents bitset (as if its callback was invoked). If the watcher isn't pending it does nothing and returns 0.
如果watcher是被挂起的，这个函数将会清空watcher的挂起状态，并且返回它的事件集标志位（就好像它的回调已经被调用过一样）。如果watcher不是被挂起的，那么此函数将什么都不做，并且返回0.

Sometimes it can be useful to "poll" a watcher instead of waiting for its callback to be invoked, which can be accomplished with this function.
有的时候，循环一个watcher而不是等待watcher调用它的回调是有用的，这个函数就完成了这个功能。

ev_feed_event (loop, ev_TYPE *watcher, int revents)
Feeds the given event set into the event loop, as if the specified event had happened for the specified watcher (which must be a pointer to an initialised but not necessarily started event watcher). Obviously you must not free the watcher as long as it has pending events.
订阅设置到event loop的给定的事件，好像对于执行watcher来说指定的事件已经发生了（watcher必须是一个已经初始化但是不一定已经启动的watcher指针）。显然，只要watcher还有未处理的事件，你就不能释放这个watcher指针。

Stopping the watcher, letting libev invoke it, or calling ev_clear_pending will clear the pending event, even if the watcher was not started in the first place.
虽然没有第一时间启动watcher，但是停止watcher，让libev调用它，或者调用ev_clear_pending来清理未触发的事件。

See also ev_feed_fd_event and ev_feed_signal_event for related functions that do not need a watcher.
另请参阅ev_feed_fd_event和ev_feed_signal_event的相关功能，它们不需要watcher参数。

See also the ASSOCIATING CUSTOM DATA WITH A WATCHER and BUILDING YOUR OWN COMPOSITE WATCHERS idioms.
另请参阅ASSOCIATING CUSTOM DATA WITH A WATCHER（watcher关联自定义数据）和BUILDING YOUR OWN COMPOSITE WATCHERS （构建你自己的watcher）部分。

WATCHER STATES
watcher 状态

There are various watcher states mentioned throughout this manual - active, pending and so on. In this section these states and the rules to transition between them will be described in more detail - and while these rules might look complicated, they usually do "the right thing”.
这本手册中提到watcher的各种状态-活跃，挂起等等。在这节中，将更详细的面熟这些状态和转换规则，虽然这些规则看起来很复杂，但是它们通常会做正确的事情。

initialised
已经初始化
Before a watcher can be registered with the event loop it has to be initialised. This can be done with a call to ev_TYPE_init, or calls to ev_init followed by the watcher-specific ev_TYPE_set function.
在watcher可以在event loop中注册之前，它必须被初始化。它可以使用调用ev_TYPE_init初始化，或者调用ev_init，接着调用watcher具体类型的ev_TYPE_set函数。

In this state it is simply some block of memory that is suitable for use in an event loop. It can be moved around, freed, reused etc. at will - as long as you either keep the memory contents intact, or call ev_TYPE_init again.
在这种状态下，watcher只是一块可以在event loop中使用的简单的内存块。它可以根据你的意愿任意的移动，释放或者再利用等等。只要保证内存中的内容不变或者再次调用ev_TYPE_init。

started/running/active
开始/运行/活跃
Once a watcher has been started with a call to ev_TYPE_start it becomes property of the event loop, and is actively waiting for events. While in this state it cannot be accessed (except in a few documented ways), moved, freed or anything else - the only legal thing is to keep a pointer to it, and call libev functions on it that are documented to work on active watchers.
一旦watcher使用ev_TYPE_start启动，event loop将接管它的所有权，并且将积极的等待事件。虽然在这种状态下它不能被访问（除了几个有据可查的方法外 PS：其实就是libev有几个允许访问的方法可以访问在这个状态下的watcher），移动，释放或者任何事情。唯一合法的事情就是保持一个指向它的指针，或者使用libev允许的方法来访问它。

pending
挂起（未处理）
If a watcher is active and libev determines that an event it is interested in has occurred (such as a timer expiring), it will become pending. It will stay in this pending state until either it is stopped or its callback is about to be invoked, so it is not normally pending inside the watcher callback.
如果watcher是活跃的，并且libev确定这个watcher的事件已经发生（例如定时器即将到期），那么watcher将变成挂起的（或者说是未处理的）。它将一直保持挂起状态，直到wacther被停止或者它的回调函数被调用，所以它一般不会在watcher的callback中被正常的挂起。

The watcher might or might not be active while it is pending (for example, an expired non-repeating timer can be pending but no longer active). If it is stopped, it can be freely accessed (e.g. by calling ev_TYPE_set), but it is still property of the event loop at this time, so cannot be moved, freed or reused. And if it is active the rules described in the previous item still apply.
当wacterh是挂起状态的时候，它是不是被激活都是有可能发生的（例如，过期并且非重复的计时器将会被挂起，但是不再是活跃的）。如果它已经被停止，那么它可以被随意的访问（例如调用ev_TYPE_set），但是这个时候，event loop仍然有这个wacther的所有权，所以不能被移动，释放，或者重用。如果这个watcher是活跃的，那么这个规则对于前一个项仍然适用。（PS：这里的item是指啥玩意？）

It is also possible to feed an event on a watcher that is not active (e.g. via ev_feed_event), in which case it becomes pending without being active.
也可以把一个事件强行提供给一个不是活跃状态的watcher（例如通过ev_feed_event），这种情况下，watcher将会在没有经过活跃状态的情况下直接到挂起状态。

stopped
A watcher can be stopped implicitly by libev (in which case it might still be pending), or explicitly by calling its ev_TYPE_stop function. The latter will clear any pending state the watcher might be in, regardless of whether it was active or not, so stopping a watcher explicitly before freeing it is often a good idea.
watcher可以通过libev隐式的停止（这种情况下，watcher可能仍然是挂起状态），或者通过调用ev_TYPE_stop函数显式的停止。后者将会清除watcher可能存在的挂起状态，无论他是活跃的还是不活跃的，所以在释放它之前先显式的停止它一般来说都是一个好主意。

While stopped (and not pending) the watcher is essentially in the initialised state, that is, it can be reused, moved, modified in any way you wish (but when you trash the memory block, you need to ev_TYPE_init it again).
在停止并且非挂起状态下，watcher基本上就是在初始化状态，也就是说，它可以按照你的想法重用，移动，更改（但是如果你释放掉这个内存块，你需要再次使用ev_TYPE_init）。

WATCHER PRIORITY MODELS
watcher的优先级模型

Many event loops support watcher priorities, which are usually small integers that influence the ordering of event callback invocation between watchers in some way, all else being equal.
很多事件循环框架支持watcher的优先级，它通常是一个影响同等条件的watcher的回调函数顺序的小整数。

In libev, Watcher priorities can be set using ev_set_priority. See its description for the more technical details such as the actual priority range.
在libev中，watcher的优先级可以通过使用ev_set_priority设置。更多的细节请参阅其函数说明，例如：实际优先级值的范围

There are two common ways how these these priorities are being interpreted by event loops:
event loops通常有两种方法来实现优先级：

In the more common lock-out model, higher priorities "lock out" invocation of lower priority watchers, which means as long as higher priority watchers receive events, lower priority watchers are not being invoked.
在常见的锁定模式中，高优先级的watcher”锁定“低优先级watchers的调用，这意味着只要高优先级的watchers接收到事件，那么低优先级的watchers将不会被调用。

The less common only-for-ordering model uses priorities solely to order callback invocation within a single event loop iteration: Higher priority watchers are invoked before lower priority ones, but they all get invoked before polling for new events.
不太常见是只做序模型，在一个单一的event loop循环内部，使用优先级作为唯一的排序依据，来回调watcher的调用：高优先级的watchers会在低优先级前面调用，但是它们都会在再次循环触发事件之前调用。

Libev uses the second (only-for-ordering) model for all its watchers except for idle watchers (which use the lock-out model).
libev使用第二种模型（只排序），除了idle watcher（它使用第一种锁定模型）。

The rationale behind this is that implementing the lock-out model for watchers is not well supported by most kernel interfaces, and most event libraries will just poll for the same events again and again as long as their callbacks have not been executed, which is very inefficient in the common case of one high-priority watcher locking out a mass of lower priority ones.
这样做的理由是，执行锁定模型，watcher不能很好的被大多数内核接口支持，并且只要它们的回调没有被执行，大多数的事件库只是一次又一次循环的触发相同的事件，在通常情况下，一个高优先级watcher锁定了大量低优先级的watcher，这效率是非常低下的。

Static (ordering) priorities are most useful when you have two or more watchers handling the same resource: a typical usage example is having an ev_io watcher to receive data, and an associated ev_timer to handle timeouts. Under load, data might be received while the program handles other jobs, but since timers normally get invoked first, the timeout handler will be executed before checking for data. In that case, giving the timer a lower priority than the I/O watcher ensures that I/O will be handled first even under adverse conditions (which is usually, but not always, what you want).
当你有两个或者多个watchers正要处理相同资源的时候，静态（排序）优先级是非常有用的：一个典型的例子就是有一个ev_io watcher接收数据，并且一个相关的ev_timer处理超时。在负债下，数据可能会在处理其他任务的时候被接收，但是由于定时器通常先被调用，超时处理程序将在验证数据之前被调用。在这种情况下，给定时器一个比io watcher低的优先级来确保io即使在不利的情况下也会被先调用（这种就是通常的解决方案，当并非总是如此。PS：what you want？怎么翻译？作者的挑衅？）。

Since idle watchers use the "lock-out" model, meaning that idle watchers will only be executed when no same or higher priority watchers have received events, they can be used to implement the "lock-out" model when required.
由于idle watchers使用”锁定“模型，这意味着idle watcher只有在没有相同或者更高的watcher接收到事件时才会被执行，当需要的时候，他们可以被用来实现”锁定“模型。


For example, to emulate how many other event libraries handle priorities, you can associate an ev_idle watcher to each such watcher, and in the normal watcher callback, you just start the idle watcher. The real processing is done in the idle watcher callback. This causes libev to continuously poll and process kernel event data for the watcher, but when the lock-out case is known to be rare (which in turn is rare :), this is workable.
举个例子，仿效其他很多事件库处理优先级，你可以给每一个watcher关联一个ev_idle，并且在正常的watcher回调中，你只是启动这个idle watcher。真正的处理过程实在idle watcher的回调中调用的。这将导致libev死循环和不断的处理watcher的内核事件，但是在锁定情况下将会是很罕见的（这又是难得的），所以这是可行的。

Usually, however, the lock-out model implemented that way will perform miserably under the type of load it was designed to handle. In that case, it might be preferable to stop the real watcher before starting the idle watcher, so the kernel will not have to process the event in case the actual processing will be delayed for considerable time.
然后，通常情况下，lock-out模型在负载类型下被设计来处理实现这种方法将会是非常糟糕的。在这种情况下，它可能最好在启动idle watcher之前先停止真实的watcher，所以在内核将不必处理这个事件的情况下，真实的处理过程将会被延迟很长时间。

Here is an example of an I/O watcher that should run at a strictly lower priority than the default, and which should only process data when no other events are pending:
这是一个io watcher运行在比默认还低的优先级，但没有任何事件被挂起并且只能处理数据的例子。

ev_idle idle; // actual processing watcher
ev_io io;     // actual event watcher

static void
io_cb (EV_P_ ev_io *w, int revents)
{
// stop the I/O watcher, we received the event, but
// are not yet ready to handle it.
//停止io watcher，我们接收这个事件，但是不准备处理它
ev_io_stop (EV_A_ w);

// start the idle watcher to handle the actual event.
// it will not be executed as long as other watchers
// with the default priority are receiving events.
//开始idle watcher来处理真实的事件
//只要另外默认优先级的watchers这在接收事件，那么将不会被执行。
ev_idle_start (EV_A_ &idle);
}

static void
idle_cb (EV_P_ ev_idle *w, int revents)
{
// actual processing
//真实的处理过程
read (STDIN_FILENO, ...);

// have to start the I/O watcher again, as
// we have handled the event
//必须重启io watcher，因为我们可以处理这个事件
ev_io_start (EV_P_ &io);
}

// initialisation
ev_idle_init (&idle, idle_cb);
ev_io_init (&io, io_cb, STDIN_FILENO, EV_READ);
ev_io_start (EV_DEFAULT_ &io);

In the "real" world, it might also be beneficial to start a timer, so that low-priority connections can not be locked out forever under load. This enables your program to keep a lower latency for important connections during short periods of high load, while not completely locking out less important ones.
在”真实“的项目中（就是在真实的项目中），启动一个定时器是有必要的，这样低优先级的连接在高负载下就不会永远被锁了。这意味着你的程序对于在短期高负载下重要的连接保持一个低延迟，而不是完全锁定那些没那么重要的连接。（也就是说先处理高优先级的，再处理低优先级的，不会只处理高优先级的）。

WATCHER TYPES

This section describes each watcher in detail, but will not repeat information given in the last section. Any initialisation/set macros, functions and members specific to the watcher type are explained.
本节介绍每一种watcher的细节，但是在最后一节我们不会给出重复的信息。任何初始化/set宏，函数和每种watcher特有的属性成员都会被介绍。

Members are additionally marked with either [read-only], meaning that, while the watcher is active, you can look at the member and expect some sensible content, but you must not modify it (you can modify it while the watcher is stopped to your hearts content), or [read-write], which means you can expect it to have some sensible content while the watcher is active, but you can also modify it. Modifying it may not do something sensible or take immediate effect (or do anything at all), but libev will not crash or malfunction in any way.
加之属性成员又被标记为只读，这意味着，当watcher是活跃的时候，你可以查看一下属性成员并且得到一些明智的内容，但是你不能更改它（当你觉得watcher被停止的时候你可以更改它。PS：是不是就是说当你觉得它不再被使用的时候，你可以更改只读属性？）；或者标记为读-写，这意味着你可以在watcher活跃的时候获得它的明智内容，但是你也可以更改它。更改读写成员，特需不会做一些明智的事情，或者不能即时生效（或者根本什么都没有做），但是libev也不会死机或者发生故障。

ev_io - is this file descriptor readable or writable?
ev_IO-是不是文件描述符可读或者可写事件？

I/O watchers check whether a file descriptor is readable or writable in each iteration of the event loop, or, more precisely, when reading would not block the process and writing would at least be able to write some data. This behaviour is called level-triggering because you keep receiving events as long as the condition persists. Remember you can stop the watcher if you don't want to act on the event and neither want to receive future events.
IO watchers在event loop每次迭代的时候检查文件描述符是可读还是可写的，或者更正确的说，当读不阻塞进程和写至少能写一点数据的时候。这种行为被成为水平触发，因为你只要条件允许，就保持接受事件。记住，如果你不想对事件采取行动也不想将来接受事件，你可以停止watcher。

In general you can register as many read and/or write event watchers per fd as you want (as long as you don't confuse yourself). Setting all file descriptors to non-blocking mode is also usually a good idea (but not required if you know what you are doing).
一般来说，每一个文件描述符你都可以注册你想注册的那些读和/或者写事件（只要你自己不要搞混）。将所有的文件描述符设置成”非阻塞“的模式也经常是一个好主意。

Another thing you have to watch out for is that it is quite easy to receive "spurious" readiness notifications, that is, your callback might be called with EV_READ but a subsequent read(2) will actually block because there is no data. It is very easy to get into this situation even with a relatively standard program structure. Thus it is best to always use non-blocking I/O: An extra read(2) returning EAGAIN is far preferable to a program hanging until some data arrives.
另一个你需要注意的是，它很容易会收到“虚假”的准备就绪通知，也就是说，你的回调函数将会被按照EV_READ方式调用，但是随后read(2)调用将会被阻塞，因为根本就没有数据。即使程序结构很标准，这种状况也很容易发生。所以，最好的办法是使用非阻塞的IO：一个特别的read(2)返回EAGAIN相比阻塞进程到数据达到会更好。

If you cannot run the fd in non-blocking mode (for example you should not play around with an Xlib connection), then you have to separately re-test whether a file descriptor is really ready with a known-to-be good interface such as poll (fortunately in the case of Xlib, it already does this on its own, so its quite safe to use). Some people additionally use SIGALRM and an interval timer, just to be sure you won't block indefinitely.
如果你将文件描述符设置成非阻塞模式（例如你不应该玩Xlib的连接 PS：Xlib的链接有什么特别吗？对Xlib不熟悉），那么你必须单独的重新测试文件描述符是否已经准备好将要良好的界面，例如poll（幸运的是，Xlib在这种情况下，他已经自己这样做了，所以可以安全的使用）。有一些人还用SIGALRM和定时器，只是要确定你将不会无限期的阻塞进程。

But really, best use non-blocking mode.
不过说真的，最好的办法还是使用非阻塞模式。

The special problem of disappearing file descriptors
不存在的文件描述符的特殊问题

Some backends (e.g. kqueue, epoll) need to be told about closing a file descriptor (either due to calling close explicitly or any other means, such as dup2). The reason is that you register interest in some file descriptor, but when it goes away, the operating system will silently drop this interest. If another file descriptor with the same number then is registered with libev, there is no efficient way to see that this is, in fact, a different file descriptor.
有一些后台（例如kqueue，epoll）需要被告知关闭文件描述符（不是由于显式的调用关闭就是任何其他手段，例如dup2）。这个原因是你注册的事件对一些文件描述符感兴趣，但是当这些文件描述符消失的时候，操作系统将默默的删除这些兴趣，如果另外一个文件描述符使用同样的文件描述符值在libev中注册，那么libev将没有有效的方法来区分实际上这是一个不同的文件描述符。

To avoid having to explicitly tell libev about such cases, libev follows the following policy: Each time ev_io_set is being called, libev will assume that this is potentially a new file descriptor, otherwise it is assumed that the file descriptor stays the same. That means that you have to call ev_io_set (or ev_io_init) when you change the descriptor even if the file descriptor number itself did not change.
为了避免不得不明确的告诉libev这种情况，libev遵循以下原则：每次ev_io_set被调用，libev都假定这可能是一个新的文件描述符，否则假定文件描述符保持不变。这意味着即使文件描述符值它自己都没有改变，当你需要改变文件描述符的时候你不得不调用ev_io_set（或者是ev_io_init）。

This is how one would do it normally anyway, the important point is that the libev application should not optimise around libev but should leave optimisations to libev.
这通常究竟是怎么做的，重要的一点是libev应用程序不应该到处优化libev，但是应该交给libev优化。

The special problem of dup'ed file descriptors
dup文件描述符的问题

Some backends (e.g. epoll), cannot register events for file descriptors, but only events for the underlying file descriptions. That means when you have dup ()'ed file descriptors or weirder constellations, and register events for them, only one file descriptor might actually receive events.
一些后台（例如epoll），仅对潜在的文件描述符事件，不能为这些文件描述符注册事件。这意味着当你用dup（）或者更怪异的方法生成的文件描述符，为他们注册事件，只有一个文件描述符事实上接收到事件。

There is no workaround possible except not registering events for potentially dup ()'ed file descriptors, or to resort to EVBACKEND_SELECT or EVBACKEND_POLL.
目前没有解决方法把可能是dup生成的文件描述符排除在注册事件之外（PS：其实就是还没有办法限制dup生成的文件描述符注册到libev），或者求助于EVBACKEND_SELECT或EVBACKEND_POLL

The special problem of files
文件的特殊问题

Many people try to use select (or libev) on file descriptors representing files, and expect it to become ready when their program doesn't block on disk accesses (which can take a long time on their own).
很多人都试着在文件描述符上用select（或者libev）来表现文件，并且在磁盘访问时，希望他们的程序变成就绪状态、不阻塞。

However, this cannot ever work in the "expected" way - you get a readiness notification as soon as the kernel knows whether and how much data is there, and in the case of open files, that's always the case, so you always get a readiness notification instantly, and your read (or possibly write) will still block on the disk I/O.
然而，在某些时候它并不能按照希望的方式工作—只要内核知道这里是否有数据或者有多少数据，你就会得到一个准备就绪的通知，并且在打开文件的情况下，通常都会是这样的。所以你通常都会瞬间得到一个准备就绪的通知，并且你的读取（也有可能是写入）将仍然阻塞在磁盘IO上。

Another way to view it is that in the case of sockets, pipes, character devices and so on, there is another party (the sender) that delivers data on its own, but in the case of files, there is no such thing: the disk will not send data on its own, simply because it doesn't know what you wish to read - you would first have to request some data.
另外一种方法来看待这个事情是在sockets，pipes，字符驱动设备等等情况下，它自己可能是发送数据的另外一方，但是磁盘文件的情况下，并不存在这样的事情：磁盘它自己不会发送数据，只是因为它不知道你想读--你必须首先请求一些数据。

Since files are typically not-so-well supported by advanced notification mechanism, libev tries hard to emulate POSIX behaviour with respect to files, even though you should not use it. The reason for this is convenience: sometimes you want to watch STDIN or STDOUT, which is usually a tty, often a pipe, but also sometimes files or special devices (for example, epoll on Linux works with /dev/random but not with /dev/urandom), and even though the file might better be served with asynchronous I/O instead of with non-blocking I/O, it is still useful when it "just works" instead of freezing.
因为文件通常都不是那么友好的支持先进的通报机制，所以libev试着力图模仿POSIX尊重文件的行为，尽管你可能不会用到它。模仿文件的原因就是因为方便：有些时候，你需要关注STDIN或者是STDOUT，它们通常是一个管道实现的tty设备，但是有些时候也是文件或者是特殊的驱动设备（例如，epoll在linux上靠/dev/random工作，但是不靠/dev/urandom），尽管文件使用异步IO替代非阻塞IO可能会被更好的送达，但是当它只要工作而不是冻结的时候，它仍然非常有用。

So avoid file descriptors pointing to files when you know it (e.g. use libeio), but use them when it is convenient, e.g. for STDIN/STDOUT, or when you rarely read from a file instead of from a socket, and want to reuse the same code path.
所以当你知道它的时候（例如使用libeio），要尽量的避免文件描述符指向文件（这里的文件应该是指磁盘文件），但是使用它们的时候很方便，例如对于标准输入/输出，或当您从文件而不是从一个socket中很好的读，并且想重用同样的代码路径。

The special problem of fork
fork的特殊问题

Some backends (epoll, kqueue) do not support fork () at all or exhibit useless behaviour. Libev fully supports fork, but needs to be told about it in the child if you want to continue to use it in the child.
一些后台（epoll，kqueue）根本不提供fork或者表现出没用的行为。libev完全支持fork，但是需要在子进程被告知，如果你想在子进程中继续使用libev。

To support fork in your child processes, you have to call ev_loop_fork () after a fork in the child, enable EVFLAG_FORKCHECK, or resort to EVBACKEND_SELECT or EVBACKEND_POLL.
为了在你的子进程中支持fork，你必须在调用fork之后的子进程中调用ev_loop_fork，开启EVFLAG_FORKCHECK或者依靠EVBACKEND_SELECT或者EVBACKEND_POLL.

The special problem of SIGPIPE
SIGPIPE信号的特殊问题

While not really specific to libev, it is easy to forget about SIGPIPE: when writing to a pipe whose other end has been closed, your program gets sent a SIGPIPE, which, by default, aborts your program. For most programs this is sensible behaviour, for daemons, this is usually undesirable.
虽然没有明确到libev，但是也容易忽略掉SIGPIPE：当你写入数据到一个另外一端已经被关闭的管道（pipe），你的程序将会发送一个SIGPIPE信号，默认情况下，会中止你程序。对于大多数程序来说这是一个明智的行为，但是对于守护进程，这通常是不可取的。

So when you encounter spurious, unexplained daemon exits, make sure you ignore SIGPIPE (and maybe make sure you log the exit status of your daemon somewhere, as that would have given you a big clue).
所以当你遇到假的，不明原因的守护进程退出，请确认你忽略了SIGPIPE（可能需要确认你记录的守护进程的退出状态，因为这会给你一个很大的线索）。

The special problem of accept()ing when you can’t
当不能accept时的特殊问题

Many implementations of the POSIX accept function (for example, found in post-2004 Linux) have the peculiar behaviour of not removing a connection from the pending queue in all error cases.
很多的POSIX accept函数的实现具有怪异的行为，它不能在错误情况下从挂起的队列中删除一个连接。

For example, larger servers often run out of file descriptors (because of resource limits), causing accept to fail with ENFILE but not rejecting the connection, leading to libev signalling readiness on the next iteration again (the connection still exists after all), and typically causing the program to loop at 100% CPU usage.
例如大型服务器通常会达到文件描述符的限制（因为有资源限制），导致了ENFILE，从而接受失败，但不拒绝连接，导致libev在写一次循环中再一次发送准备就绪的信号（毕竟连接仍然是存在的），并且通常导致程序在loop的时候CPU使用率100%。

Unfortunately, the set of errors that cause this issue differs between operating systems, there is usually little the app can do to remedy the situation, and no known thread-safe method of removing the connection to cope with overload is known (to me).
不幸的是，在不同操作系统之间会造成不同的错误，通常有很少的应用程序可以做到亡羊补牢​​，并且也不知道去除连接，以应付超负荷运转的线程安全的函数 （对我来说）。

One of the easiest ways to handle this situation is to just ignore it - when the program encounters an overload, it will just loop until the situation is over. While this is a form of busy waiting, no OS offers an event-based way to handle this situation, so it's the best one can do.
处理这种问题的其中一种办法是忽略它--当程序遇到高负载的时候，继续loop程序，直到这种情况结束。虽然忙着等待只是一个形式，当没有一个OS提供一个基于事件的处理这种情况的方法，所以，这是能做的方法中最好的一个了。

A better way to handle the situation is to log any errors other than EAGAIN and EWOULDBLOCK, making sure not to flood the log with such messages, and continue as usual, which at least gives the user an idea of what could be wrong ("raise the ulimit!"). For extra points one could stop the ev_io watcher on the listening fd "for a while", which reduces CPU usage.
一个更好的处理这种情况的办法是记录任何错误，除了EAGAIN和EWOULDBLOCK，确保不要使用如此的信息来填充日志，并且继续像往常一样，这至少给用户一个什么是错误的想法（“提高ulimit限制值）。另外的一点，可以在监听的文件描述符上停止ev_io watcher一会儿，这会降低cpu的使用率。

If your program is single-threaded, then you could also keep a dummy file descriptor for overload situations (e.g. by opening /dev/null), and when you run into ENFILE or EMFILE, close it, run accept, close that fd, and create a new dummy fd. This will gracefully refuse clients under typical overload conditions.
如果你的程序是单线程的，你也可以为了过载保留一个虚拟的文件描述符（例如通过打开/dev/null),当你遇到ENFILE或者EMFILE的时候，关闭它，运行接收，关闭那个文件描述符，并且创建一个新的虚拟文件描述符。这将在典型的负载条件下，优雅地拒绝客户端。

The last way to handle it is to simply log the error and exit, as is often done with malloc failures, but this results in an easy opportunity for a DoS attack.
最后处理它的方法是简单的记录下来error并且退出，如经常使用malloc失败做，但这也导致了给DoS攻击提供了一个简单的机会。

Watcher-Specific Functions

ev_io_init (ev_io *, callback, int fd, int events)
ev_io_set (ev_io *, int fd, int events)
Configures an ev_io watcher. The fd is the file descriptor to receive events for and events is either EV_READ, EV_WRITE or EV_READ | EV_WRITE, to express the desire to receive the given events.
设置一个ev_io的watcher，fd是用来接收事件的文件描述符，events用来表示要接收事件的类型，分别是EV_READ，EV_WRITE或者EV_READ|EV_WRITE之一。

int fd [read-only]
The file descriptor being watched.
被关注的文件描述符

int events [read-only]
The events being watched.
被关注的事件类型

Examples

Example: Call stdin_readable_cb when STDIN_FILENO has become, well readable, but only once. Since it is likely line-buffered, you could attempt to read a whole line in the callback.
当STDIN_FILENO可读的时候调用stdin_readable_cb函数，但是callback只运行一次。因为STDIN_FILENO有点像”行缓存“，所以你可以尝试在对调用读取一个完整的行。

static void
stdin_readable_cb (struct ev_loop *loop, ev_io *w, int revents)
{
ev_io_stop (loop, w);
.. read from stdin here (or from w->fd) and handle any I/O errors
//在这里从stdin中读取（或者从watcher的fd中读取），并且处理任何的IO错误
}

...
struct ev_loop *loop = ev_default_init (0);
ev_io stdin_readable;
ev_io_init (&stdin_readable, stdin_readable_cb, STDIN_FILENO, EV_READ);
ev_io_start (loop, &stdin_readable);
ev_run (loop, 0);

ev_timer - relative and optionally repeating timeouts
ev_timer 相对和随意的重复过期

Timer watchers are simple relative timers that generate an event after a given time, and optionally repeating in regular intervals after that.
定时器watchers是简单的在给定时间之后产生一个事件的相对定时器，并且此后有规律的随意重复。

The timers are based on real time, that is, if you register an event that times out after an hour and you reset your system clock to January last year, it will still time out after (roughly) one hour. "Roughly" because detecting time jumps is hard, and some inaccuracies are unavoidable (the monotonic clock option helps a lot here).
定时器基于实时的（PS：其实就是实际的时间），这意味着如果你注册一个一个小时后过期的事件，并且你重新设置你的系统时钟到去年的1月份，它仍然（大约）会在一个小时后超时。大概的原因是因为探测时间跳跃是比较苦难的，并且一些误差是无法避免的（这里单调的时钟选项帮助了很多）。

The callback is guaranteed to be invoked only after its timeout has passed (not at, so on systems with very low-resolution clocks this might introduce a small delay, see "the special problem of being too early", below). If multiple timers become ready during the same loop iteration then the ones with earlier time-out values are invoked before ones of the same priority with later time-out values (but this is no longer true when a callback calls ev_run recursively).
只有超时时间已经过了，回调是保证被调用的（不全是这样的，在一些时钟分辨率低的系统上，可能会有小小的延迟，详情请查阅下面的“过早的特殊问题”）。如果在同一个loop迭代中，有多个定时器变得就绪，更早超时的定时器比同优先级下晚超时的定时器早调用（但当回调递归的调用ev_run时，这个规则将不起作用）。


Be smart about timeouts
聪明的超时

Many real-world problems involve some kind of timeout, usually for error recovery. A typical example is an HTTP request - if the other side hangs, you want to raise some error after a while.
很多真实世界的问题涉及到某种超时，经常用于错误恢复。一个典型的例子就是一个http的请求-如果另外一边hangs，你想在一会儿后抛出错误。

What follows are some ways to handle this problem, from obvious and inefficient to smart and efficient.
紧跟着的是一些处理这个事情的方法，这些方法从容易和无效率到聪明和有效率的。

In the following, a 60 second activity timeout is assumed - a timeout that gets reset to 60 seconds each time there is activity (e.g. each time some data or other life sign was received).
下面假设一个60秒活跃超时的定时器-即每次活跃的时候重新设置60秒超时（例如：每次接收到一些数据或者是其他的生存信号）。

Use a timer and stop, reinitialise and start it on activity.
This is the most obvious, but not the most simple way: In the beginning, start the watcher:
让一个活跃的定时器停止，重新初始化并且启动它。

ev_timer_init (timer, callback, 60., 0.);
ev_timer_start (loop, timer);

Then, each time there is some activity, ev_timer_stop it, initialise it and start it again:
这样，每次活跃的时候，ev_timer_stop停止它，再初始化和启动它：

ev_timer_stop (loop, timer);
ev_timer_set (timer, 60., 0.);
ev_timer_start (loop, timer);

This is relatively simple to implement, but means that each time there is some activity, libev will first have to remove the timer from its internal data structure and then add it again. Libev tries to be fast, but it's still not a constant-time operation.
这相对来说是容易实现的，当这意味着每次活跃的时候，libev先必须从他的内部数据结构中移除这个定时器，然后再加上它。libev试着更快的实现，但是这仍然不是一个常数级的操作。

2. Use a timer and re-start it with ev_timer_again inactivity.
This is the easiest way, and involves using ev_timer_again instead of ev_timer_start.
使用定时器，并且使用ev_timer_again重启它。
这是简单的方法，并且涉及使用ev_timer_again替换ev_timer_start。

To implement this, configure an ev_timer with a repeat value of 60 and then call ev_timer_again at start and each time you successfully read or write some data. If you go into an idle state where you do not expect data to travel on the socket, you can ev_timer_stop the timer, and ev_timer_again will automatically restart it if need be.
为了实现这些，使用一个60秒重复的值来设置ev_timer，并且在开始和每次你成功的读取或者写数据的时候调用ev_timer_again。如果你进入到一个空闲的状态，你没有预料到数据会流经socket，你可以ev_timer_stop来停止定时器，并且如果需要，ev_timer_again将自动的重启定时器。

That means you can ignore both the ev_timer_start function and the after argument to ev_timer_set, and only ever use the repeat member and ev_timer_again.
这意味着你可以忽略ev_timer_start函数和ev_timer_set的after参数。只要使用重复属性和ev_timer_again就可以。

At start:

ev_init (timer, callback);
timer->repeat = 60.;
ev_timer_again (loop, timer);

Each time there is some activity:
每次活跃的时候：

ev_timer_again (loop, timer);

It is even possible to change the time-out on the fly, regardless of whether the watcher is active or not:
它甚至可能能在运行的时候改变超时的值，不管watcher是活跃的还是不活跃的：

timer->repeat = 30.;
ev_timer_again (loop, timer);

This is slightly more efficient then stopping/starting the timer each time you want to modify its timeout value, as libev does not have to completely remove and re-insert the timer from/into its internal data structure.
当每次停止/启动定时器，你想改变这个过期时间时，这是很有效的，因为libev没有从他的内部数据结构中移除和重新插入定时器。

It is, however, even simpler than the "obvious" way to do it.
所以不管怎么说，相比明显的方法（stop，restart）来实现它，它（使用again）是更简单的。

3. Let the timer time out, but then re-arm it as required.
设定定时器超时，但是需要的时候的重新准备。

This method is more tricky, but usually most efficient: Most timeouts are relatively long compared to the intervals between other activity - in our example, within 60 seconds, there are usually many I/O events with associated activity resets.
这个方式是比较投机取巧的，当通常也是效率比较高的。大多数的超时相对其他活动来说时间是比较长的-在我们的例子中，在60秒内，通常有很多IO事件已经被重置了。

In this case, it would be more efficient to leave the ev_timer alone, but remember the time of last activity, and check for a real timeout only within the callback:
在这种情况下，让ev_timer单独出来将是比较有效率的，但是要记住最后活跃的时间，并且在callback内部检查真实的超时。

ev_tstamp timeout = 60.;
ev_tstamp last_activity; // time of last activity 最后活跃的时间
ev_timer timer;

static void
callback (EV_P_ ev_timer *w, int revents)
{
// calculate when the timeout would happen
//计算什么时候发生的超时
ev_tstamp after = last_activity - ev_now (EV_A) + timeout;

// if negative, it means we the timeout already occurred
//如果小于0，那么表示超时已经发生
if (after < 0.)
{
// timeout occurred, take action
}
else
{
// callback was invoked, but there was some recent 
// activity. simply restart the timer to time out
// after "after" seconds, which is the earliest time
// the timeout can occur.
//回调函数被调用，但是这是一些近来的活动，不是这个定时器的。
//简单重置定时器超时时间，这个时间是超时最早可以发生的时间
//PS:难道libev的定时器和epoll一样，有“伪信号”问题？
ev_timer_set (w, after, 0.);
ev_timer_start (EV_A_ w);
}
}

To summarise the callback: first calculate in how many seconds the timeout will occur (by calculating the absolute time when it would occur, last_activity + timeout, and subtracting the current time, ev_now (EV_A) from that).
概述整个回调函数：首先，计算还有多少秒超时将会发生（通过就算，计算结果的绝对值就是将要发生的时间，last_activity + timeout，然后减去ev_now返回的当前时间）。

If this value is negative, then we are already past the timeout, i.e. we timed out, and need to do whatever is needed in this case.
如果这个值是负数，我们已经比超时晚了，即我们已经超时了，在这种情况下，就要去做任何需要做的事情了。

Otherwise, we now the earliest time at which the timeout would trigger, and simply start the timer with this timeout value.
要不然，我们现在比超时将要触发早，并且简单的使用超时时间值启动定时器。

In other words, each time the callback is invoked it will check whether the timeout occurred. If not, it will simply reschedule itself to check again at the earliest time it could time out. Rinse. Repeat.
换句话说，每次回调被调用，都要检查超时是否已经发生。如果没有，自己简单的重新安排时间来在它可能超时的最早时间再次检查。再次重新安排，如此重复。

This scheme causes more callback invocations (about one every 60 seconds minus half the average time between activity), but virtually no calls to libev to change the timeout.
这种策略导致更多的回调被调用（大约每60秒减去活动之间平均时间的一半），但是事实上没有调用libev来改变超时时间。

To start the machinery, simply initialise the watcher and set last_activity to the current time (meaning there was some activity just now), then call the callback, which will "do the right thing" and start the timer:
要开始这样的体系，简单的初始化watcher，并且设置last_activity到当前时间（意味着刚刚有些一些活动），然后调用回调函数，然后做正确的事情，并且开始这个定时器：

last_activity = ev_now (EV_A);
ev_init (&timer, callback);
callback (EV_A_ &timer, 0);

When there is some activity, simply store the current time in last_activity, no libev calls at all:
当有一些活动时，简单的把当前时间值保存到last_activity，根本没有调用libev：


if (activity detected)
last_activity = ev_now (EV_A);

When your timeout value changes, then the timeout can be changed by simply providing a new value, stopping the timer and calling the callback, which will again do the right thing (for example, time out immediately :).
当超时时间改变的时候，可以通过一个简单的值来更改，停止这个定时器，并且调用回调，然后再一次做正确的事情（例如：立刻超时）。

timeout = new_value;
ev_timer_stop (EV_A_ &timer);
callback (EV_A_ &timer, 0);

This technique is slightly more complex, but in most cases where the time-out is unlikely to be triggered, much more efficient.
这种技巧稍微有点复杂，但是更多情况下，超时是不太可能被触发的，这样更有效率一些。

4. Wee, just use a double-linked list for your timeouts.
很早的时候超时只是使用一个双链表

If there is not one request, but many thousands (millions...), all employing some kind of timeout with the same timeout value, then one can do even better:
如果这不是一个请求，而是成千上万个（数百万个），所有的同类型超时都有相同的超时值，那么这样（使用双链表）可以做的更好。

When starting the timeout, calculate the timeout value and put the timeout at the end of the list.
当启动定时器的时候，计算超时值并且把定时器放在列表的最后面。

Then use an ev_timer to fire when the timeout at the beginning of the list is expected to fire (for example, using the technique #3).
当列表头部的定时器希望被触发的时候，使用一个ev_timer来触发（例如，使用技巧3）。

When there is some activity, remove the timer from the list, recalculate the timeout, append it to the end of the list again, and make sure to update the ev_timer if it was taken from the beginning of the list.
当定时器活跃的时候，从列表中移除定时器，重新计算超时时间，再次把它加到列表的最后，并且如果定时器来自列表的头部，那么确保更新ev_timer。

This way, one can manage an unlimited number of timeouts in O(1) time for starting, stopping and updating the timers, at the expense of a major complication, and having to use a constant timeout. The constant timeout ensures that the list stays sorted.
这种方法，可以使用O（1）的算法复杂度来管理无限数量的定时器，启动，停止和更新这些定时器，最大的困难是性能开销，并且不得不使用一个固定的超时。固定的超时确保列表保持排序。

So which method the best?
所以哪个方法是最好的？

Method #2 is a simple no-brain-required solution that is adequate in most situations. Method #3 requires a bit more thinking, but handles many cases better, and isn't very complicated either. In most case, choosing either one is fine, with #3 being better in typical situations.
方法2是简单的不用想的解决方案，这个方案在大多数情况下已经够用。方法3需要稍微想一下，但是在很多情况下都会处理的更好，并且也不是太复杂。在大多数情况下，选择任何一个都很好，再典型的情况下，方法3会更好。

Method #1 is almost always a bad idea, and buys you nothing. Method #4 is rather complicated, but extremely efficient, something that really pays off after the first million or so of active timers, i.e. it's usually overkill :)
方法1几乎都是一个挺烂的解决方案，并且带给你任何东西。方法4太复杂，但非常有效，通常百万或者同等数量的定时器没有问题（PS：根据想象翻译了，有更好的翻译嘛？）。通常，它都是比较过度的。

The special problem of being too early
被提前超时的问题

If you ask a timer to call your callback after three seconds, then you expect it to be invoked after three seconds - but of course, this cannot be guaranteed to infinite precision. Less obviously, it cannot be guaranteed to any precision by libev - imagine somebody suspending the process with a STOP signal for a few hours for example.
如果你想一个定时器在3秒后调用你的回调函数，那么你期望3秒过后回调函数将被调用（这不是废话？？）—当然，不能给你确保无限精度。显然，libev不能确保任何的精确性-；例如，一些人使用STOP信号挂起进程几个小时。

So, libev tries to invoke your callback as soon as possible after the delay has occurred, but cannot guarantee this.
所以，libev试着在延时发生后尽可能快的调用回调函数，但是不能保证这一点。

A less obvious failure mode is calling your callback too early: many event loops compare timestamps with a "elapsed delay >= requested delay", but this can cause your callback to be invoked much earlier than you would expect.
一个不太明显的模式是调用你的回调函数太早了：很多event loops比较“经过延迟>=需要延迟”的时间戳，但是这将可能会导致比你期望更早的调用你的回调函数。

To see why, imagine a system with a clock that only offers full second resolution (think windows if you can't come up with a broken enough OS yourself). If you schedule a one-second timer at the time 500.9, then the event loop will schedule your timeout to elapse at a system time of 500 (500.9 truncated to the resolution) + 1, or 501.
来看看为什么，一个系统时钟只提供了2秒的精度（想想wins，如果你不能在一个自身中断足够的操作系统）。当时间在500.9的时候，如果你设置了一个1s的定时器，那么，event loop将在系统过500（500.9被截尾）+1，触发你的超时，或者是过了501.

If an event library looks at the timeout 0.1s later, it will see "501 >= 501" and invoke the callback 0.1s after it was started, even though a one-second delay was requested - this is being "too early", despite best intentions.
如果一个事件库看起来超时了0.1s，它将判断“501 >= 501”，并且在启动后的0.1s调用回调函数，尽管其实需要1s的延迟-这就太早了，尽管意图是好的。

This is the reason why libev will never invoke the callback if the elapsed delay equals the requested delay, but only when the elapsed delay is larger than the requested delay. In the example above, libev would only invoke the callback at system time 502, or 1.1s after the timer was started.
这就是为什么libev永远也不会在真实的超时等于预想的超时时调用回调函数的原因，但是相比预想的回调时间只会稍微玩一会儿。在上面的示例中，libev只会在系统时间502或者在启动定时器1.1s之后调用回调函数。

So, while libev cannot guarantee that your callback will be invoked exactly when requested, it can and does guarantee that the requested delay has actually elapsed, or in other words, it always errs on the "too late" side of things.
所以，当libev不能保证按照你的需求及时调用你的回调函数的时候，它可以并且确实保证需要的延迟已经到了，或者换句话说，对于按时回调来说，它总是犯“为时已晚”的错误。

The special problem of time updates
更新时间的问题

Establishing the current time is a costly operation (it usually takes at least one system call): EV therefore updates its idea of the current time only before and after ev_run collects new events, which causes a growing difference between ev_now () and ev_time () when handling lots of events in one iteration.
获取当前时间是一个代价高昂的操作（至少需要一个系统调用）：EV因此只在rv_run获取新的事件之前和之后才会更新当前时间，这意味这如果在一个迭代中处理了很多的事件，那么ev_now（）和ev_time（）的值将会不想等。

The relative timeouts are calculated relative to the ev_now () time. This is usually the right thing as this timestamp refers to the time of the event triggering whatever timeout you are modifying/starting. If you suspect event processing to be delayed and you need to base the timeout on the current time, use something like the following to adjust for it:
相对超时时间是根据ev_now来计算的。这通常是正确的，因为这个时间戳来自于事件触发的事件，不管你更改/启动这个超时。如果你怀疑事件处理被延迟并且你需要使用基于当前时间的超时，使用如下的步骤调整它：

ev_timer_set (&timer, after + (ev_time () - ev_now ()), 0.);

If the event loop is suspended for a long time, you can also force an update of the time returned by ev_now () by calling ev_now_update (), although that will push the event time of all outstanding events further into the future.
如果event loop被挂起很久了，你也可以强制使用ev_now_update更新时间，然后使用ev_now返回的时间，尽管这样做会把还没有处理的事件延迟的稍晚一些。

The special problem of unsynchronised clocks
时钟不同步的问题

Modern systems have a variety of clocks - libev itself uses the normal "wall clock" clock and, if available, the monotonic clock (to avoid time jumps).
现代系统有各种时钟-libev自己使用常见的“挂钟”时钟，如果可能，也会使用单调时钟（避免时间跳跃）。

Neither of these clocks is synchronised with each other or any other clock on the system, so ev_time () might return a considerably different time than gettimeofday () or time (). On a GNU/Linux system, for example, a call to gettimeofday might return a second count that is one higher than a directly following call to time.
任何一个系统时钟或者时钟两两之间都是不同步的，所以ev_time的返回值可能和gettimeofday或者time返回的值完全不同。在linux系统上，例如，调用gettimeofday返回的秒数可能比接着直接调用time数值高。

The moral of this is to only compare libev-related timestamps with ev_time () and ev_now (), at least if you want better precision than a second or so.
这样做的意义仅仅只是比较使用ev_time和ev_now返回的libev相关的时间戳，至少你可以有比一秒更好的精度。

One more problem arises due to this lack of synchronisation: if libev uses the system monotonic clock and you compare timestamps from ev_time or ev_now from when you started your timer and when your callback is invoked, you will find that sometimes the callback is a bit “early".
还有一个问题会由于缺乏同步出现：如果libev使用系统单调时钟并且当你启动你的定时器并且回调已经被调用时，你比较由ev_time或者ev_now返回的时间戳，你将会发现有的时候回调被早调用了。

This is because ev_timers work in real time, not wall clock time, so libev makes sure your callback is not invoked before the delay happened, measured according to the real time, not the system clock.
这是因为ev_timer工作在真实的时间，不是时钟时间，所以libev确保在延迟到期之前不会调用你的回调函数，因为ev_timer是按照真实的时间判断，而不是按照时钟时间。

If your timeouts are based on a physical timescale (e.g. "time out this connection after 100 seconds") then this shouldn't bother you as it is exactly the right behaviour.
如果你的超时是基于物理时间表（例如100s之后这个连接超时），那么这应该不会打扰你，因为它是一个完全正确的行为。

If you want to compare wall clock/system timestamps to your timers, then you need to use ev_periodics, as these are based on the wall clock time, where your comparisons will always generate correct results.
如果你想为你的定时器比较时钟/系统时间戳，那么你需要使用ev_periodics，因为是ev_periodics基于时钟的，你的比较都会产生正确的结果。

The special problems of suspended animation
假死的问题

When you leave the server world it is quite customary to hit machines that can suspend/hibernate - what happens to the clocks during such a suspend?
当你离开了服务器领域，你可以完全的控制你的机器，你可以暂停/休眠-那么在这个延迟中间，时钟发生了什么？

Some quick tests made with a Linux 2.6.28 indicate that a suspend freezes all processes, while the clocks (times, CLOCK_MONOTONIC) continue to run until the system is suspended, but they will not advance while the system is suspended. That means, on resume, it will be as if the program was frozen for a few seconds, but the suspend time will not be counted towards ev_timer when a monotonic clock source is used. The real time clock advanced as expected, but if it is used as sole clocksource, then a long suspend would be detected as a time jump by libev, and timers would be adjusted accordingly.
在linux 2.6.28上做一些快速的测试，表明暂停并且冻结所有的进程，当时钟（时间，单调时钟）继续运行直到系统被暂停，当他们不会提前当系统暂停。这就意味着，在重新启动的时候，这将会像程序被冻结了几秒钟，但是当单调时钟被使用的时候，暂停时间不会被计算到ev_timer。真实的时间按照预期那样运行，但如果它是被使用的唯一的时间源，那么一个长的暂停将会被libev作为一个时间跳跃检测到，并且定时器会按照这个时间跳跃调整。


I would not be surprised to see different behaviour in different between operating systems, OS versions or even different hardware.
我也不会在看到在不同的操作系统，操作系统版本或者是不同的硬件之间存在不同的行为而感到惊讶。

The other form of suspend (job control, or sending a SIGSTOP) will see a time jump in the monotonic clocks and the realtime clock. If the program is suspended for a very long time, and monotonic clock sources are in use, then you can expect ev_timers to expire as the full suspension time will be counted towards the timers. When no monotonic clock source is in use, then libev will again assume a timejump and adjust accordingly.
暂停的另外一种形式（作业控制，或者发生一个SIGSTOP信号）将会看到在单调时钟和真实的时钟中有时间跳跃。如果程序被暂停了很多时间，并且使用单调时钟源，那么随着所有的暂停时间将被计算到定时器，你可以期望ev_timers终止。当不是使用单调时钟源时，那么libev将再假定一次时间跳跃，并且相应的调整。


It might be beneficial for this latter case to call ev_suspend and ev_resume in code that handles SIGTSTP, to at least get deterministic behaviour in this case (you can do nothing against SIGSTOP).
后一种方法对于调用ev_suspend和ec_resume来处理SIGTSP是有利的，至少在这种情况下有一个稳定的行为（靠SIGSTOP你将不能做任何事情）。

Watcher-Specific Functions and Data Members
watcher-特殊的函数和数据成员

ev_timer_init (ev_timer *, callback, ev_tstamp after, ev_tstamp repeat)
ev_timer_set (ev_timer *, ev_tstamp after, ev_tstamp repeat)
Configure the timer to trigger after after seconds. If repeat is 0., then it will automatically be stopped once the timeout is reached. If it is positive, then the timer will automatically be configured to trigger again repeat seconds later, again, and again, until stopped manually.
配置定时器在after秒之后触发。如果repeat为0，那么定时器在超时一次后自动的停止。如果repeat是正数，那么定时器将会一次又一次的循环触发，直到你手动停止为止。

The timer itself will do a best-effort at avoiding drift, that is, if you configure a timer to trigger every 10 seconds, then it will normally trigger at exactly 10 second intervals. If, however, your program cannot keep up with the timer (because it takes longer than those 10 seconds to do stuff) the timer will not fire more than once per event loop iteration.
定时器自己会尽最大的努力避免重叠，也就说，如果你配置一个定时器每10s触发一次，那么它通常会在整整10s的时候被触发，但是，如果你的程序不能在10s内完成回调（因为回调可能需要比10s更长的时间），那么定时器将不会在每次event loop迭代中触发大于一次（PS：是不是也就是说，如果callback耗时比timer的时间间隔长，那么下一次的回调将不会被调用？）。

ev_timer_again (loop, ev_timer *)
This will act as if the timer timed out, and restarts it again if it is repeating. It basically works like calling ev_timer_stop, updating the timeout to the repeat value and calling ev_timer_start.
如果定时器超时，并且如果定时器是重复的，那么此函数会重启它。这基本上工作起来类似于点用ev_timer_stop，更新超时的重复值，然后再调用ev_timer_start。

The exact semantics are as in the following rules, all of which will be applied to the watcher:
确切的意思如下所述，所有的这些规则都会应用到watcher：

If the timer is pending, the pending status is always cleared.
如果定时器被挂起，那么挂起状态一直被清零。
If the timer is started but non-repeating, stop it (as if it timed out, without invoking it).
如果定时器被启动但是不是重复的，停止它（就像定时器超时，但是不调用它）。
If the timer is repeating, make the repeat value the new timeout and start the timer, if necessary.
如果定时器是重复的，如果必要，把新的超时值设置成重复的值，并且启动定时器。
This sounds a bit complicated, see Be smart about timeouts, above, for a usage example.
这听起来有点复杂，上面有关于超时用法的章节示例。

ev_tstamp ev_timer_remaining (loop, ev_timer *)
Returns the remaining time until a timer fires. If the timer is active, then this time is relative to the current event loop time, otherwise it's the timeout value currently configured.
返回离定时器被触发的时间。如果定时器是活跃的，那么这个时间就是相对于当前event loop的时间，否则，这就是当前配置额的超时时间。

That is, after an ev_timer_set (w, 5, 7), ev_timer_remaining returns 5. When the timer is started and one second passes, ev_timer_remaining will return 4. When the timer expires and is restarted, it will return roughly 7 (likely slightly less as callback invocation takes some time, too), and so on.
也就是说，在调用ev_timer_set（w，5，7）之后，ev_timer_remaining返回5.当定时器被启动，并且过了1s时间，ev_timer_remaining将返回4.当定时器超时，并且被重启，那么它将返回大约是7（也有可能会比7少一些，因为调用回调函数也需要一些时间），等等。

ev_tstamp repeat [read-write]
The current repeat value. Will be used each time the watcher times out or ev_timer_again is called, and determines the next timeout (if any), which is also when any modifications are taken into account.
当前重复值。每个监视器超时或ev_timer_again被调用时将被使用，并且确定下一个超时值（如果有的话） ，这也是当任何修改都考虑在内。

Examples

Example: Create a timer that fires after 60 seconds.
示例：创建一个60s后触发的定时器。

static void
one_minute_cb (struct ev_loop *loop, ev_timer *w, int revents)
{
.. one minute over, w is actually stopped right here
}

ev_timer mytimer;
ev_timer_init (&mytimer, one_minute_cb, 60., 0.);
ev_timer_start (loop, &mytimer);

Example: Create a timeout timer that times out after 10 seconds of inactivity.
示例：创建一个定时器，10s之内不活动


static void
timeout_cb (struct ev_loop *loop, ev_timer *w, int revents)
{
.. ten seconds without any activity
//10s内没有任何活动
}

ev_timer mytimer;
ev_timer_init (&mytimer, timeout_cb, 0., 10.); /* note, only repeat used 注意，只用了repeat*/

ev_timer_again (&mytimer); /* start timer  启动定时器*/
ev_run (loop, 0);

// and in some piece of code that gets executed on any "activity":
// reset the timeout to start ticking again at 10 seconds
//PS：这句怎么翻译？
ev_timer_again (&mytimer);

ev_periodic - to cron or not to cron?
ev_periodoc-克隆或者不克隆

Periodic watchers are also timers of a kind, but they are very versatile (and unfortunately a bit complex).
periodic watchers也是一种定时器，但是他们用途非常多（可惜有点复杂）。

Unlike ev_timer, periodic watchers are not based on real time (or relative time, the physical time that passes) but on wall clock time (absolute time, the thing you can read on your calender or clock). The difference is that wall clock time can run faster or slower than real time, and time jumps are not uncommon (e.g. when you adjust your wrist-watch).
不像ev_timer，periodic watchers不是基于真实事件的（或者相对时间，经过的物理时间），但是基于时钟时间（绝对时间，你可以在你的日历或者钟表上读到的时间）。不同的是挂钟时间可以比真实时间跑的更快或者更慢，并且时间跳跃也是经常发生的（比如，当你调整你手表的时候）。

You can tell a periodic watcher to trigger after some specific point in time: for example, if you tell a periodic watcher to trigger "in 10 seconds" (by specifying e.g. ev_now () + 10., that is, an absolute time not a delay) and then reset your system clock to January of the previous year, then it will take a year or more to trigger the event (unlike an ev_timer, which would still trigger roughly 10 seconds after starting it, as it uses a relative timeout).
你可以告诉你的periodic watcher在指定的时间点之后触发：比如，如果你告诉一个periodic watcher在10s后触发（通过指定如ev_now（） +10，也就说，一个不延迟的绝对时间）并且重设你的系统时间到去年的一个月，那么periodic将会在至少1年的时间来触发事件（不像ev_timer，ev_timer仍然会在开始的10s之后触发，因为它使用的是相对时间）。

ev_periodic watchers can also be used to implement vastly more complex timers, such as triggering an event on each "midnight, local time", or other complicated rules. This cannot be done with ev_timer watchers, as those cannot react to time jumps.
ev_periodic watchers也可以被用来实现复杂的多的定时器，比如每个本地的午夜触发事件，或者另外复杂的规则。这是不能用ev_timer来实现的，因为ev_timer不能对于时间跳跃做出更好的反映。

As with timers, the callback is guaranteed to be invoked only when the point in time where it is supposed to trigger has passed. If multiple timers become ready during the same loop iteration then the ones with earlier time-out values are invoked before ones with later time-out values (but this is no longer true when a callback calls ev_run recursively).
如果定时器 ，只有当这个触发事件的时间点已经过了，回调函数才是保证被调用的，如果在同一个循环迭代中有多个定时器变的就绪，那么早超时的定时器比晚超时的定时器早调用（当回调函数中递归的调用ev_run时，这个规则会被打破）。

Watcher-Specific Functions and Data Members
watcher-特殊的函数和数据成员

ev_periodic_init (ev_periodic *, callback, ev_tstamp offset, ev_tstamp interval, reschedule_cb)
ev_periodic_set (ev_periodic *, ev_tstamp offset, ev_tstamp interval, reschedule_cb)
Lots of arguments, let's sort it out... There are basically three modes of operation, and we will explain them from simplest to most complex:
参数很多，让我们整理一下。基本上有3种操作模式，我们将从最简单的开始到最复杂的这样解释：

* absolute timer (offset = absolute time, interval = 0, reschedule_cb = 0)
    In this configuration the watcher triggers an event after the wall clock time offset has passed. It will not repeat and will not adjust when a time jump occurs, that is, if it is to be run at January 1st 2011 then it will be stopped and invoked when the system clock reaches or surpasses this point in time.
    绝对时间（offset = 绝对时间, interval = 0, reschedule_cb = 0）
    在这个配置中，watcher会在时钟过了offset这个时间点触发一个事件。它不会重复并且也不会随着时间的跳跃进行调整，也就是说，如果watcher将在2011-01-01运行，那么watcher会在时钟到了或者超过这个时间点的时候停止并且调用。

* repeating interval timer (offset = offset within interval, interval > 0, reschedule_cb = 0)
    In this mode the watcher will always be scheduled to time out at the next offset + N * interval time (for some integer N, which can also be negative) and then repeat, regardless of any time jumps. The offset argument is merely an offset into the interval periods.
    重复的间隔时间（offset＝间隔时间，interval>0,reschedule_cb=0)
    在这个模式中，watcher将一直被安排在下一个offset + N*interval时间（N也可能是负数）时触发，并且重复，任何的jumps也不会起作用。offset参数仅仅只是一个间隔周期的补偿而已。

    This can be used to create timers that do not drift with respect to the system clock, for example, here is an ev_periodic that triggers each hour, on the hour (with respect to UTC):
    这可以用来创建一个和系统时钟时间跳跃无关的定时器，例如，这里的ev_periodic每个小时触发一次，整整一个小时（相对于UTC来说）

    ev_periodic_set (&periodic, 0., 3600., 0);

    This doesn't mean there will always be 3600 seconds in between triggers, but only that the callback will be called when the system time shows a full hour (UTC), or more correctly, when the system time is evenly divisible by 3600.
    这并不意味着每次触发的时间间隔都是3600s，但也仅仅当系统时间显示整整一个小时（UTC）的时候，回调函数才会被调用，或者更准确的说，当系统时间为3600整除的时候才会触发事件（PS：难道那么多废话就是为了表达“整点”）。

    Another way to think about it (for the mathematically inclined) is that ev_periodic will try to run the callback in this mode at the next possible time where time = offset (mod interval), regardless of any time jumps.
    考虑这个问题（为了数学倾向）的另一种方式就是ev_periodic将试着在这种模式下在下一个时间点time＝offset（取余interval）时运行回调，不会理会任何的时间跳跃。

    The interval MUST be positive, and for numerical stability, the interval value should be higher than 1/8192 (which is around 100 microseconds) and offset should be higher than 0 and should have at most a similar magnitude as the current time (say, within a factor of ten). Typical values for offset are, in fact, 0 or something between 0 and interval, which is also the recommended range.
    时间间隔必须是正数，并且数值稳定的。这个值应该大于1/8192（大约100微妙），误差应该大于0最大和现在时间一个数量级的数（比方说，是小于10的因数）。典型的误差值，事实上是0或者0-时间间隔之间，这也是推荐的范围。

    Note also that there is an upper limit to how often a timer can fire (CPU speed for example), so if interval is very small then timing stability will of course deteriorate. Libev itself tries to be exact to be about one millisecond (if the OS supports it and the machine is fast enough).

    还要注意的是，有一个多久可以触发定时器的上限（例如CPU的速度），所以如果时间间隔非常小，那么时序的稳定性肯定会变差。Libev自己会试着去稳定在1毫秒（如果OS提供这个精度并且机器足够快）。

    manual reschedule mode (offset ignored, interval ignored, reschedule_cb = callback)
    手动重新排序模式（offset 忽略，interval 忽略，reschedule_cb＝callback）
    In this mode the values for interval and offset are both being ignored. Instead, each time the periodic watcher gets scheduled, the reschedule callback will be called with the watcher as first, and the current time as second argument.
    在这个模式中，offset和interval的值都被忽略。相反的，每次periodic watcher都会被排序，首先会使用watcher作为参数来调用重新排序的回调函数，并且当前时间作为第二个参数。

    NOTE: This callback MUST NOT stop or destroy any periodic watcher, ever, or make ANY other event loop modifications whatsoever, unless explicitly allowed by documentation here.
    注意：除非文档明确允许这样做，否则这个回调必须不能停止或者释放任何的periodic watcher，或者无论什么也不能对event loop做出任何的修改。

    If you need to stop it, return now + 1e30 (or so, fudge fudge) and stop it afterwards (e.g. by starting an ev_prepare watcher, which is the only event loop modification you are allowed to do).
    如果你需要停止这个periodic，返回now + 1e30（左后）然后停止它（例如通过启动一个ev_prepare watcher，它是唯一一个被允许修改event loop的）。

    The callback prototype is ev_tstamp (*reschedule_cb)(ev_periodic *w, ev_tstamp now), e.g.:
    回调的原型签名 ev_tstamp (*reschedule_cb)(ev_periodic *w, ev_tstamp now),

    static ev_tstamp
    my_rescheduler (ev_periodic *w, ev_tstamp now)
    {
    return now + 60.;
    }

    It must return the next time to trigger, based on the passed time value (that is, the lowest time value larger than to the second argument). It will usually be called just before the callback will be triggered, but might be called at other times, too.
    它必须返回下一次触发的时间，这个时间是基于经过时间值的（即，比第二个参数大的最小值）。它经常就在回调被触发之前被调用，但是也有可能在别的时间被调用。


NOTE: This callback must always return a time that is higher than or equal to the passed now value.
注意：回调函数必须一直返回一个高于或者等于当前已经过去时间的值。

This can be used to create very complex timers, such as a timer that triggers on "next midnight, local time". To do this, you would calculate the next midnight after now and return the timestamp value for this. How you do this is, again, up to you (but it is not trivial, which is the main reason I omitted it as an example).
它可以被用来创建一个非常复杂的定时器，例如一个在“下一个本地的午夜”触发的定时器。为了做这些，你要计算下一个午夜离现在多少时间，并且要返回这个时间戳。你怎么做？再一次，由你决定（但是它并不是不重要的，这就是我省略它来作为例子的最大原因）。

ev_periodic_again (loop, ev_periodic *)
Simply stops and restarts the periodic watcher again. This is only useful when you changed some parameters or the reschedule callback would return a different time than the last time it was called (e.g. in a crond like program when the crontabs have changed).
只是再一次停止并且重启periodic watcher。只有当你改变一些参数或者重新排列回调函数将返回和回调函数被调用时最新的时间不同的时间时是有用的。（例如在一个克隆的程序中当crontabs已经改变）。（PS：这段怎么翻译？德国人写的E文也是nm看不懂的玩意）。

ev_tstamp ev_periodic_at (ev_periodic *)
When active, returns the absolute time that the watcher is supposed to trigger next. This is not the same as the offset argument to ev_periodic_set, but indeed works even in interval and manual rescheduling modes.
如果watcher是活跃的，返回watcher下一次触发的绝对时间。这个ev_periodic_set的offset参数不同，但是不管是在interval还是手动重排模式，都确实能工作。

ev_tstamp offset [read-write]
When repeating, this contains the offset value, otherwise this is the absolute point in time (the offset value passed to ev_periodic_set, although libev might modify this value for better numerical stability).
当重复的时候，它包含了offset的值，否则它据说一个绝对的时间点（offset传递给ev_periodic_set，尽管libev可能会为了数值稳定性更改这个值）。

Can be modified any time, but changes only take effect when the periodic timer fires or ev_periodic_again is being called.
可以在任何时候更改，但是更改只有在periodic定时器触发或者ev_periodic_again再一次被调用时有效。

ev_tstamp interval [read-write]
The current interval value. Can be modified any time, but changes only take effect when the periodic timer fires or ev_periodic_again is being called.
当前间隔时间。任何时候都可以被更改，但是只有在periodic定时器被触发或者ev_periodic_again被调用时才有效。

ev_tstamp (*reschedule_cb)(ev_periodic *w, ev_tstamp now) [read-write]
The current reschedule callback, or 0, if this functionality is switched off. Can be changed any time, but changes only take effect when the periodic timer fires or ev_periodic_again is being called.
当前重排的回调函数，或者是空的。如果这个功能被关闭，那么任何时候都可以更改，但是更改只有当periodic被触发或者ev_periodic_again被调用时才有效。

Examples

Example: Call a callback every hour, or, more precisely, whenever the system time is divisible by 3600. The callback invocation times have potentially a lot of jitter, but good long-term stability.
示例：每一个小时调用一个回调，或者更确切的说，是当系统时间是3600的整数倍时。这个回调函数被调用的时间可能会有点波动，但基本拥有良好的长期稳定性。

static void
clock_cb (struct ev_loop *loop, ev_periodic *w, int revents)
{
... its now a full hour (UTC, or TAI or whatever your clock follows)
}

ev_periodic hourly_tick;
ev_periodic_init (&hourly_tick, clock_cb, 0., 3600., 0);
ev_periodic_start (loop, &hourly_tick);

Example: The same as above, but use a reschedule callback to do it:
示例：和上面一样，但是使用重排回调函数来做。

#include <math.h>

static ev_tstamp
my_scheduler_cb (ev_periodic *w, ev_tstamp now)
{
return now + (3600. - fmod (now, 3600.));
}

ev_periodic_init (&hourly_tick, clock_cb, 0., 0., my_scheduler_cb);

Example: Call a callback every hour, starting now:
示例：每小时调用一次回调函数，现在开始。

ev_periodic hourly_tick;
ev_periodic_init (&hourly_tick, clock_cb,
fmod (ev_now (loop), 3600.), 3600., 0);
ev_periodic_start (loop, &hourly_tick);



ev_signal - signal me when a signal gets signalled!
ev_signal-当一个信号被触发的时候通知我

Signal watchers will trigger an event when the process receives a specific signal one or more times. Even though signals are very asynchronous, libev will try its best to deliver signals synchronously, i.e. as part of the normal event processing, like any other event.
当进程一次或者多次接收到一个指定的信号时，signal watchers将触发一个事件。即使信号是异步信号，libev将尽力给予信号同步，就像其他事件一样，作为正常事件处理的一部分。

If you want signals to be delivered truly asynchronously, just use sigaction as you would do without libev and forget about sharing the signal. You can even use ev_async from a signal handler to synchronously wake up an event loop.
如果你想让信号真正的异步，只有使用sigaction，你这样做不需要libev并且忘记共享信号。你也可以在一个信号处理程序中使用ev_async来同步唤醒一个event loop。

You can configure as many watchers as you like for the same signal, but only within the same loop, i.e. you can watch for SIGINT in your default loop and for SIGIO in another loop, but you cannot watch for SIGINT in both the default loop and another loop at the same time. At the moment, SIGCHLD is permanently tied to the default loop.
你可以根据你想要的配置很多watchers监听同一个信号，但是只能在同一个loop之内。即你可以在默认的loop上监听SIGINT，在另外一个loop上肩痛SIGIO，但是你不能同时在默认的loop和另外一个loop上都监听SIGINT，大多数时候，SIGCHLD是一直在默认的loop上的。

Only after the first watcher for a signal is started will libev actually register something with the kernel. It thus coexists with your own signal handlers as long as you don't register any with libev for the same signal.
只有在监听信号的第一个watcher被启动后，libev才实际上在内核中注册了一些东西。只要你没有给同样的信号在libev上注册，它就以这种方式来解决你自己的信号处理函数

If possible and supported, libev will install its handlers with SA_RESTART (or equivalent) behaviour enabled, so system calls should not be unduly interrupted. If you have a problem with system calls getting interrupted by signals you can block all signals in an ev_check watcher and unblock them in an ev_prepare watcher.
如果可能并且支持的呼哈，libev将会使用开启SA_RESTART（或者同等效果）的行为来注册它的处理函数，所以系统调用不应该过分中断。如果你有一个关于系统调用造成信号中断的问题，那么你可以在ev_check watcher中阻止所有的在信号，并且在ev_preare watcher中解除阻止。

The special problem of inheritance over fork/execve/pthread_create
继承fore/execve/pthread_create的问题

Both the signal mask (sigprocmask) and the signal disposition (sigaction) are unspecified after starting a signal watcher (and after stopping it again), that is, libev might or might not block the signal, and might or might not set or restore the installed signal handler (but see EVFLAG_NOSIGMASK).
在启动信号watcher之后（在再一次停止它之后），信号掩码（sigprocmask）和信号处理程序没有被指定，也就是说，libev可能会或者也可能不会阻塞这个信号，并且可能会也可能不会设置或者重新设置信号的处理函数（但是要看EVFLAG_NOSIGMASK参数）。
PS：在启动信号watcher之后？这句话怎么理解？应该是之前吧？

While this does not matter for the signal disposition (libev never sets signals to SIG_IGN, so handlers will be reset to SIG_DFL on execve), this matters for the signal mask: many programs do not expect certain signals to be blocked.
虽然这对于信号处理并不要紧（libev从未设置SIG_IGN信号，所以在execve的时候，处理程序将会被重新设置到SIG_DFL），对于信号掩码重要的是：很多程序不希望某些信号被阻塞住。

This means that before calling exec (from the child) you should reset the signal mask to whatever "default" you expect (all clear is a good choice usually).
这意味着，在调用exec之前（从子进程中）你要重新设置信号掩码到你希望的默认状态（通常，把所有的都清除掉是一个好的选择）。

The simplest way to ensure that the signal mask is reset in the child is to install a fork handler with pthread_atfork that resets it. That will catch fork calls done by libraries (such as the libc) as well.
这个简单的方法来确保信号掩码是在子进程中被重置的，并且使用pthread_atfork来注册一个fork的处理程序来重置信号掩码。这还不如通过程序库来捕捉fork调用（例如libc）。

In current versions of libev, the signal will not be blocked indefinitely unless you use the signalfd API (EV_SIGNALFD). While this reduces the window of opportunity for problems, it will not go away, as libev has to modify the signal mask, at least temporarily.
在当前的libev版本中，信号是不会被无限期的阻塞的，除非你使用signalfd API(EV_SIGNALFD).虽然那这样做拖延了问题的被发现的时机，但是问题不会消失，因为libev可以更改信号掩码，至少目前是这样的。

So I can't stress this enough: If you do not reset your signal mask when you expect it to be empty, you have a race condition in your code. This is not a libev-specific thing, this is true for most event libraries.
所以我不能强调这一点：当你期望你的信号掩码是空的时候，如果你不能重置你的信号掩码，你可以在你的代码中有一个竞争的条件。这不是libev特有的，这对于大多数event库来说都是对的。

The special problem of threads signal handling
线程信号处理函数的问题

POSIX threads has problematic signal handling semantics, specifically, a lot of functionality (sigfd, sigwait etc.) only really works if all threads in a process block signals, which is hard to achieve.
POSIX线程有有问题的信号处理语义，说明确一些，很多的功能（sigfd sigwait等）只能真正的工作只进程中所有的线程阻塞信号，这是很难实现的。

When you want to use sigwait (or mix libev signal handling with your own for the same signals), you can tackle this problem by globally blocking all signals before creating any threads (or creating them with a fully set sigprocmask) and also specifying the EVFLAG_NOSIGMASK when creating loops. Then designate one thread as "signal receiver thread" which handles these signals. You can pass on any signals that libev might be interested in by calling ev_feed_signal.
当你想使用sigwait（或者对于同样的信号混合你自己的libev的信号处理程序），你可以通过在创建任何线程（或者使用一个完全的集合sigprocmask创建它们）之前全局阻塞所有的信号解决这个问题，或者也可以当创建loop时指定EVFLAG_NOSIGMASK参数。然后指定一个线程为“信号接收线程”来处理这些信号。你可以传递任何信号，libev可能通过调用ev_feed_signal对这些信号感兴趣。

Watcher-Specific Functions and Data Members

ev_signal_init (ev_signal *, callback, int signum)
ev_signal_set (ev_signal *, int signum)
Configures the watcher to trigger on the given signal number (usually one of the SIGxxx constants).
配置watcher来触发给定的信号

int signum [read-only]
The signal the watcher watches out for.
watcher监听到的信号

Examples

Example: Try to exit cleanly on SIGINT.

static void
sigint_cb (struct ev_loop *loop, ev_signal *w, int revents)
{
ev_break (loop, EVBREAK_ALL);
}

ev_signal signal_watcher;
ev_signal_init (&signal_watcher, sigint_cb, SIGINT);
ev_signal_start (loop, &signal_watcher);

ev_child - watch out for process status changes
ev_child-监控进程状态的改变

Child watchers trigger when your process receives a SIGCHLD in response to some child status changes (most typically when a child of yours dies or exits). It is permissible to install a child watcher after the child has been forked (which implies it might have already exited), as long as the event loop isn't entered (or is continued from a watcher), i.e., forking and then immediately registering a watcher for the child is fine, but forking and registering a watcher a few event loop iterations later or in the next callback invocation is not.
当你的进程对于一些子进程状态的改变收到一个SIGCHLD信号的响应时，子进程watcher触发（最典型的是当你的子进程死掉或者退出）。它允许在子进程被fork之后，注册一个子进程的watcher（这意味这它可能已经退出了），只要event loop没有被进入（或者从一个watcher继续循环），即fork子进程然后马上为子进程注册一个watcher的正确的做法，但是fork一个子进程，然后在一些event loop循环迭代后注册一个watcher，或者在下一次的回调函数调用中注册watcher，这些方法是不正确的。

Only the default event loop is capable of handling signals, and therefore you can only register child watchers in the default event loop.
只有默认的event loop能处理信号，因此你只能在默认event loop中注册子进程的watcher。

Due to some design glitches inside libev, child watchers will always be handled at maximum priority (their priority is set to EV_MAXPRI by libev)
由于libev内部的一些设计问题，子进程的watchers一直被设计成拥有最大的优先级（它们的优先级被libev设置成EV_MAXPRI）。

Process Interaction
进程的作用

Libev grabs SIGCHLD as soon as the default event loop is initialised. This is necessary to guarantee proper behaviour even if the first child watcher is started after the child exits. The occurrence of SIGCHLD is recorded asynchronously, but child reaping is done synchronously as part of the event loop processing. Libev always reaps all children, even ones not watched.
只要默认的event loop已经被初始化，libev就可以捕获SIGCHLD。
即使第一个子进程watcher在子进程退出后被启动，这对于保证适当的行为也是必须的。SIGHLD的发生被记录是异步的，但是子进程把它作为event loop处理过程的一部分来同步进程。libev一直循环所有的子进程，即使是那些没有被监控的。


Overriding the Built-In Processing
覆盖内置的处理

Libev offers no special support for overriding the built-in child processing, but if your application collides with libev's default child handler, you can override it easily by installing your own handler for SIGCHLD after initialising the default loop, and making sure the default loop never gets destroyed. You are encouraged, however, to use an event-based approach to child reaping and thus use libev's support for that, so other libev users can use ev_child watchers freely.
libev对于覆盖内置的子进程处理，没有提供特殊的支持，但是如果你的应用程序与libev默认的子进程处理函数有冲突，你可以在初始化默认的loop之后给SIGCHLD信号注册你自己的处理函数，从而简单的覆盖它，并且确保默认的loop永远不会被释放。这是被鼓励的，不管怎么样，为了使用一个event-base处理子进程迭代并且因此使用libev支持它，所以另外的libev用户可以自由的使用ev_child wahcter。

Stopping the Child Watcher

Currently, the child watcher never gets stopped, even when the child terminates, so normally one needs to stop the watcher in the callback. Future versions of libev might stop the watcher automatically when a child exit is detected (calling ev_child_stop twice is not a problem).
目前，子进程watcher永远不会停止，即使子进程退出，所以通常需要在回调中停止watcher。libev未来的版本可能会增加当子进程退出时自动停止watcher（调用ev_child_stop两次并不是一个问题）。

Watcher-Specific Functions and Data Members
watcher-特殊的函数和数据成员

ev_child_init (ev_child *, callback, int pid, int trace)
ev_child_set (ev_child *, int pid, int trace)
Configures the watcher to wait for status changes of process pid (or any process if pid is specified as 0). The callback can look at the rstatus member of the ev_child watcher structure to see the status word (use the macros from sys/wait.h and see your systems waitpid documentation). The rpid member contains the pid of the process causing the status change. trace must be either 0 (only activate the watcher when the process terminates) or 1 (additionally activate the watcher when the process is stopped or continued).
配置watcher用来等待进程id为pid的进程改变状态（如果pid为0，监控任意进程）。在回调函数中可以查看ev_child watcher结构的rstatus成员来查看状态消息（使用sys/wat.h中的宏，详细请查看waitpid文档）。rpid成员包括改变状态的pid，trace必须是0（只有当进程退出，watcher是活跃的）或者是1（当进程被停止或者继续的时候额外添加活跃的watcher）。

int pid [read-only]
The process id this watcher watches out for, or 0, meaning any process id.
watcher监控的进程id，如果是0，表示任何进程

int rpid [read-write]
The process id that detected a status change.
检测到状态发生变化的进程id

int rstatus [read-write]
The process exit/trace status caused by rpid (see your systems waitpid and sys/wait.h documentation for details).
通过rpid引起进程退出或者跟踪的状态（详细查看你的系统waitpid和sys/wait.h文档）


Examples

Example: fork() a new process and install a child handler to wait for its completion.
示例：for一个新的进程，并且注册一个子进程处理函数来等到进程结束。

ev_child cw;

static void
child_cb (EV_P_ ev_child *w, int revents)
{
ev_child_stop (EV_A_ w);
printf ("process %d exited with status %x\n", w->rpid, w->rstatus);
}

pid_t pid = fork ();

if (pid < 0)
// error
else if (pid == 0)
{
// the forked child executes here
exit (1);
}
else
{
ev_child_init (&cw, child_cb, pid, 0);
ev_child_start (EV_DEFAULT_ &cw);
}

ev_stat - did the file attributes just change?
ev_stat-就改变了文件属性？

This watches a file system path for attribute changes. That is, it calls stat on that path in regular intervals (or when the OS says it changed) and sees if it changed compared to the last time, invoking the callback if it did. Starting the watcher stat's the file, so only changes that happen after the watcher has been started will be reported.
ev_stat监控文件系统路径的属性变化。相当于在路径上有规律的调用stat来查看是不是和上一次调用stat时的状态不一样了，如果是，那么调用回调函数。启动watcher监控文件，只有在watcher被启动以后熟悉发生改变才会被报告。

The path does not need to exist: changing from "path exists" to "path does not exist" is a status change like any other. The condition "path does not exist" (or more correctly "path cannot be stat'ed") is signified by the st_nlink field being zero (which is otherwise always forced to be at least one) and all the other fields of the stat buffer having unspecified contents.
路径并不需要存在：从路径存在到路径不存在的改变是一种状态的改变，就像其他的改变一样。”路径不存在“的条件（或者更确切的说是”路径不能被stat“）是通过st_nlink字段变成0指定的（换种说法就是一直被迫编程另外一种），并且所有stat buffer另外的字段内容也不确定。


The path must not end in a slash or contain special components such as . or ... The path should be absolute: If it is relative and your working directory changes, then the behaviour is undefined.
Since there is no portable change notification interface available, the portable implementation simply calls stat(2) regularly on the path to see if it changed somehow. You can specify a recommended polling interval for this case. If you specify a polling interval of 0 (highly recommended!) then a suitable, unspecified default value will be used (which you can expect to be around five seconds, although this might change dynamically). Libev will also impose a minimum interval which is currently around 0.1, but that's usually overkill.
路径必须不能一斜线或者特殊字符结束，比如.或者..。路径必须是绝对路径，如果它是相对路径，并且你的工作目录被改变，那么ev_stat的行为就是未定义的。由于没有便捷的改变通知接口可用，所以就简单的在路径上调用stat（2）来实现便捷通知，以达到查看路径是否改变。你可以指定调用stat的时间间隔。如果你把时间间隔设置成0（强烈推荐），那么就使用默认值（默认值大概在5s左右，但是也会动态的改变）。libev支持最小的时间间隔为0.1s，但是这个值经常是太过度了。

This watcher type is not meant for massive numbers of stat watchers, as even with OS-supported change notifications, this can be resource-intensive.
这种watcher类型一般不是为了大量的stat watchers考虑的，因为即使使用系统支持的改变通知接口，这也是很耗资源的。


At the time of this writing, the only OS-specific interface implemented is the Linux inotify interface (implementing kqueue support is left as an exercise for the reader. Note, however, that the author sees no way of implementing ev_stat semantics with kqueue, except as a hint).
到目前为止，只有linux实现了通知接口（使用kqueue实现一个接口作为读者的一个练习。注意，不管怎么说，作者都觉得不能使用kqueue来实现ev_stat的语义，除非暗地里有变通）。

ABI Issues (Largefile Support)
ABI问题（大文件的支持）

Libev by default (unless the user overrides this) uses the default compilation environment, which means that on systems with large file support disabled by default, you get the 32 bit version of the stat structure. When using the library from programs that change the ABI to use 64 bit file offsets the programs will fail. In that case you have to compile libev with the same flags to get binary compatibility. This is obviously the case with any flags that change the ABI, but the problem is most noticeably displayed with ev_stat and large file support.
libev在默认情况（除非你改变它）使用默认的编译环境，这意味着在系统上默认的是关闭大文件支持的，你得到的32位的stat结构。当把使用32位程序库的程序改变ABI到使用64位系统时将会失败。这种情况下，你必须使用同样的参数来编译libev以获取二进制的支持。这是显然的情况，使用任何标志来改变ABI，但问题是大多数使用ev_stat和大文件支持的显式的显示。


The solution for this is to lobby your distribution maker to make large file interfaces available by default (as e.g. FreeBSD does) and not optional. Libev cannot simply switch on large file support because it has to exchange stat structures with application programs compiled using the default compilation environment.
这个问题的解决方案就是忽悠你的系统发行商默认支持大文件接口可用而不是选用（就像freebsd一样）。libev不能简单的切换大文件支持，因为它要使用默认的编译环境编译应用程序来交换stat结构。

Inotify and Kqueue
通知和kqueue

When inotify (7) support has been compiled into libev and present at runtime, it will be used to speed up change detection where possible. The inotify descriptor will be created lazily when the first ev_stat watcher is being started.
当支持inotify（7）被编译进libev并且运行，它将被尽可能的用来提升改变侦测的速度。inotify描述符将会在第一个ev_stat watcher开始的时候被惰性的创建。

Inotify presence does not change the semantics of ev_stat watchers except that changes might be detected earlier, and in some cases, to avoid making regular stat calls. Even in the presence of inotify support there are many cases where libev has to resort to regular stat polling, but as long as kernel 2.6.25 or newer is used (2.6.24 and older have too many bugs), the path exists (i.e. stat succeeds), and the path resides on a local filesystem (libev currently assumes only ext2/3, jfs, reiserfs and xfs are fully working) libev usually gets away without polling.
inotify的存在并不改变ev_stat watcher的语义，除非改变可能被侦测的更早，并且在某些情况下，避免正常的stat调用。即使在inotify的载体存在有许多的情况下， libev也不得不诉诸定期统计轮询，但是只要内核2.6.25或者更新的被使用（2.6.24或者更老的有很多bug），路径存在（级stat成功），以及路径是本地路径（libev当前支持只有ext2/3，ifs，reiserfs和xfs），libev经常不需要polling就被触发了。

There is no support for kqueue, as apparently it cannot be used to implement this functionality, due to the requirement of having a file descriptor open on the object at all times, and detecting renames, unlinks etc. is difficult.
不对kqueue进行支持，显然它不能被用来实现这个功能，，因为在一个对象上打开一个文件描述符，并且重新命名，将解除等的要求是困难的。

stat () is a synchronous operation
stat（）是同步操作

Libev doesn't normally do any kind of I/O itself, and so is not blocking the process. The exception are ev_stat watchers - those call stat (), which is a synchronous operation.
libev通常自己不会做任何类型的IO类型，所以不会阻塞进程。唯一的另外是ev_stat watchers-他们调用stat（），这是同步操作。

For local paths, this usually doesn't matter: unless the system is very busy or the intervals between stat's are large, a stat call will be fast, as the path data is usually in memory already (except when starting the watcher).
对于本地路径，这通常不是那么重要：除非系统非常忙碌或者间隔时间很大，stat调用通常都很快，因为路径的stat数据通常都是已经在内存里面的（除了watcher启动的时候）。

For networked file systems, calling stat () can block an indefinite time due to network issues, and even under good conditions, a stat call often takes multiple milliseconds.
对于网络文件系统，调用stat（）可能阻塞一段不定的时间用来处理网络问题，并且即使网络条件不错，一个stat调用通常也要话费掉好几毫秒。

Therefore, it is best to avoid using ev_stat watchers on networked paths, although this is fully supported by libev.
因此，最好不要吧ev_stat watchers用在远程路径上，尽管libev完全支持它。

The special problem of stat time resolution
stat时间精度的问题

The stat () system call only supports full-second resolution portably, and even on systems where the resolution is higher, most file systems still only support whole seconds.
stat（）系统调用仅提供正秒的精度支持，即使系统的精度再高，大多数文件系统仍然只提供正秒的精度支持。

That means that, if the time is the only thing that changes, you can easily miss updates: on the first update, ev_stat detects a change and calls your callback, which does something. When there is another update within the same second, ev_stat will be unable to detect unless the stat data does change in other ways (e.g. file size).
这意味着，如果你仅仅改变的是文件的时间，那么你可能很容易就会错过更新：在第一次更新的时候，ev_stat发现了一个改变并且调用你的回调，执行回调函数。当在同一秒再一次更新的时候，ev_stat将不能发现这个时间更新除非用另外一种方法更新了别的stat数据（比如文件大小）。

The solution to this is to delay acting on a change for slightly more than a second (or till slightly after the next full second boundary), using a roughly one-second-delay ev_timer (e.g. ev_timer_set (w, 0., 1.02); ev_timer_again (loop, w)).
解决方案就是延迟一秒来更新（或者在一下秒之后），使用一个1秒的ev_timer（例如：ev_timer_set (w, 0., 1.02); ev_timer_again (loop, w)）。

The .02 offset is added to work around small timing inconsistencies of some operating systems (where the second counter of the current time might be be delayed. One such system is the Linux kernel, where a call to gettimeofday might return a timestamp with a full second later than a subsequent time call - if the equivalent of time () is used to update file times then there will be a small window where the kernel uses the previous second to update file times but libev might already execute the timer callback).
.02的误差被加进来来解决系统之间的时间误差（当前时间的计数器可能会被延迟。就像linux内核系统，调用gettimeofday可能返回一个正秒时间戳大于紧跟其后的time调用-如果相当于time（）时间被用来更新文件时间，那么将会有一个小的误差窗口，内核会使用前一秒来更新文件时间，但是libev可能已经执行了这个timer的回调了）。
PS：其实说白了，就是系统时间有误差，所以，需要加一个误差时间来弥补这个误差造成的更新被忽略问题。

Watcher-Specific Functions and Data Members
watcher-特有的函数和数据成员

ev_stat_init (ev_stat *, callback, const char *path, ev_tstamp interval)
ev_stat_set (ev_stat *, const char *path, ev_tstamp interval)
Configures the watcher to wait for status changes of the given path. The interval is a hint on how quickly a change is expected to be detected and should normally be specified as 0 to let libev choose a suitable value. The memory pointed to by path must point to the same path for as long as the watcher is active.
配置一个watcher来等到给定路径的状态的改变。interval是一个暗示多久发生一个变化被发现，通常指定为0，让libev自己决定这个值。只要watcher是可用的，path都只想一个相同的路径。

The callback will receive an EV_STAT event when a change was detected, relative to the attributes at the time the watcher was started (or the last change was detected).
当改变被发现的时候，回调函数将会接收到一个EV_STAT事件。相当于在这个时候对于属性来说，watcher被启动了（或者最后一个变化被检测到）。

ev_stat_stat (loop, ev_stat *)
Updates the stat buffer immediately with new values. If you change the watched path in your callback, you could call this function to avoid detecting this change (while introducing a race condition if you are not the only one changing the path). Can also be useful simply to find out the new values.
立即获取新的stat数据。如果你在回调函数中更改监控路径，你可以调用这个函数来避免检测到这个变化（如果你不仅仅改变监控的路径，需要引入急诊条件）。也可以简单的获取新的stat值。

ev_statdata attr [read-only]
The most-recently detected attributes of the file. Although the type is ev_statdata, this is usually the (or one of the) struct stat types suitable for your system, but you can only rely on the POSIX-standardised members to be present. If the st_nlink member is 0, then there was some error while stating the file.
最近检测到的文件属性。尽管类型是ev_statdata，当这通常都是适合你系统的stat结构数据（或者之一），但是你只能依靠POSIX标准成员来处理。如果st_nlink成员是0，那么检测的文件出现了一些错误。

ev_statdata prev [read-only]
The previous attributes of the file. The callback gets invoked whenever prev != attr, or, more precisely, one or more of these members differ: st_dev, st_ino, st_mode, st_nlink, st_uid, st_gid, st_rdev, st_size, st_atime, st_mtime, st_ctime.
文件属性的前一个值。当prev！＝attr的时候，回调函数被调用，或者更正确的说，一个或者多个成员不同的时候：st_dev, st_ino, st_mode, st_nlink, st_uid, st_gid, st_rdev, st_size, st_atime, st_mtime, st_ctime.


ev_tstamp interval [read-only]
The specified interval.
指定时间间隔

const char *path [read-only]
The file system path that is being watched.
待监控的文件系统路径

Examples

Example: Watch /etc/passwd for attribute changes.
示例：监控/etc/passwd的属性改变

static void
passwd_cb (struct ev_loop *loop, ev_stat *w, int revents)
{
/* /etc/passwd changed in some way */
//改变密码文件
if (w->attr.st_nlink)
{
printf ("passwd current size  %ld\n", (long)w->attr.st_size);
printf ("passwd current atime %ld\n", (long)w->attr.st_mtime);
printf ("passwd current mtime %ld\n", (long)w->attr.st_mtime);
}
else
/* you shalt not abuse printf for puts */
puts ("wow, /etc/passwd is not there, expect problems. "
"if this is windows, they already arrived\n");
}

...
ev_stat passwd;

ev_stat_init (&passwd, passwd_cb, "/etc/passwd", 0.);
ev_stat_start (loop, &passwd);

Example: Like above, but additionally use a one-second delay so we do not miss updates (however, frequent updates will delay processing, too, so one might do the work both on ev_stat callback invocation and on ev_timer callback invocation).
示例：同上，但是增加使用一个一秒的延迟，所以我们不会错过更新（但是，频繁的更新会延迟处理，因为太多了，所以ev_stat和ev_timer的回调调用都会被调用）。

static ev_stat passwd;
static ev_timer timer;

static void
timer_cb (EV_P_ ev_timer *w, int revents)
{
ev_timer_stop (EV_A_ w);

/* now it's one second after the most recent passwd change */
}

static void
stat_cb (EV_P_ ev_stat *w, int revents)
{
/* reset the one-second timer */
ev_timer_again (EV_A_ &timer);
}

...
ev_stat_init (&passwd, stat_cb, "/etc/passwd", 0.);
ev_stat_start (loop, &passwd);
ev_timer_init (&timer, timer_cb, 0., 1.02);

ev_idle - when you've got nothing better to do…
ev_idle-当你没有什么更好的事情做的时候

Idle watchers trigger events when no other events of the same or higher priority are pending (prepare, check and other idle watchers do not count as receiving “events").
当没有另外的同级别或者更高优先级的事件未触发时，触发Idle事件。

That is, as long as your process is busy handling sockets or timeouts (or even signals, imagine) of the same or higher priority it will not be triggered. But when your process is idle (or only lower-priority watchers are pending), the idle watchers are being called once per event loop iteration - until stopped, that is, or your process receives more events and becomes busy again with higher priority stuff.
这就是说，只要你的进程忙于处理同级别或者更高级别的sockets或者timeout（或者信号等）事件，Idle watcher将不会被触发。但是当你的进程处于空闲状态（或者只有低优先级的watchers未被处理），idle watcher将会每次event loop循环被调用一次直到停止，或者你的进程接收到很多事件又再一次被高优先级的事件变的忙碌。

The most noteworthy effect is that as long as any idle watchers are active, the process will not block when waiting for new events.
最值得一提的是，只要任何idle watchers是活跃的，那么进程在等待新事件的时候不会阻塞。

Apart from keeping your process non-blocking (which is a useful effect on its own sometimes), idle watchers are a good place to do "pseudo-background processing", or delay processing stuff to after the event loop has handled all outstanding events.
除了保持你的进程非阻塞（在自己的事件上面这是有用的效果），idle watchers是一个做“伪后台”处理的好时候，或者把事件延迟到event loop处理完所有的未解决事件以后在处理。


Abusing an ev_idle watcher for its side-effect
滥用ev_idle导致的副作用
As long as there is at least one active idle watcher, libev will never sleep unnecessarily. Or in other words, it will loop as fast as possible. For this to work, the idle watcher doesn't need to be invoked at all - the lowest priority will do.
只要有一个活跃的idle watcher，libev将永远没必要休眠。或者换句话说，libev将尽可能快的循环，为了这个工作，idle watcher是完全没必要被调用的-所以，最小的优先级就可以保证libev无休止循环了。

This mode of operation can be useful together with an ev_check watcher, to do something on each event loop iteration - for example to balance load between different connections.
这种模式和ev_check watcher一起使用将是非常有用的，每次循环的时候都做一些事情-比如在不同的连接之间做负载均衡。

See Abusing an ev_check watcher for its side-effect for a longer example.
详情请查看滥用ev_check watcher导致副作用的更长的例子。

Watcher-Specific Functions and Data Members

ev_idle_init (ev_idle *, callback)
Initialises and configures the idle watcher - it has no parameters of any kind. There is a ev_idle_set macro, but using it is utterly pointless, believe me.
初始化和配置idle watcher-它没有任何类型的参数，这是一个ev_idle_set宏，但是使用它是毫无意义的，相信我。

Examples

Example: Dynamically allocate an ev_idle watcher, start it, and in the callback, free it. Also, use no error checking, as usual.
例子：动态的分配一个ev_idle watcher，启动它，并且在回调函数中，释放它。同样，经常不用错误检测。

static void
idle_cb (struct ev_loop *loop, ev_idle *w, int revents)
{
// stop the watcher
ev_idle_stop (loop, w);

// now we can free it
free (w);

// now do something you wanted to do when the program has
// no longer anything immediate to do.
}

ev_idle *idle_watcher = malloc (sizeof (ev_idle));
ev_idle_init (idle_watcher, idle_cb);
ev_idle_start (loop, idle_watcher);

ev_prepare and ev_check - customise your event loop!
ev_prepare和ev_check  自定义你的event loop

Prepare and check watchers are often (but not always) used in pairs: prepare watchers get invoked before the process blocks and check watchers afterwards.
prepare和check通常（但不是一直）都是成对使用的：prepare watchers在处理块之前（PS：应该是循环loop，调用各个回调函数之前）被调用，check watcer在之后被调用。

You must not call ev_run (or similar functions that enter the current event loop) or ev_loop_fork from either ev_prepare or ev_check watchers. Other loops than the current one are fine, however. The rationale behind this is that you do not need to check for recursion in those watchers, i.e. the sequence will always be ev_prepare, blocking, ev_check so if you have one watcher of each kind they will always be called in pairs bracketing the blocking call.
你不能在ev_prepare或者ev_check watchers中调用ev_run（或者能进入当前循环的类似的函数）或者ev_loop_fork。不管怎么说，其他的循环相比当前循环都是好的。这样做的理由是你不需要在另外一些watchers中检查递归了。即，循序一直是ev_prepare，阻塞，ev_check。所以如果你每一种类型都有一个watcher，那么他们将一直成对的被包装在阻塞调用中被调用。


Their main purpose is to integrate other event mechanisms into libev and their use is somewhat advanced. They could be used, for example, to track variable changes, implement your own watchers, integrate net-snmp or a coroutine library and lots more. They are also occasionally useful if you cache some data and want to flush it before blocking (for example, in X programs you might want to do an XFlush () in an ev_prepare watcher).
它们的主要目的是集成另外的事件机制到libev中并且他们的用法是稍微有点高级的。他们可以被用来，例如，跟踪变量的变化，实现你自己的watchers，继承net-snmp或者一个协同库，或者更多。如果你想缓存一些数据并且想在阻塞之前刷新到磁盘，那么它们对此也是支持的（例如，在X程序中，你可能想在ev_prepare watcher中做一个XFlush（）操作）。

This is done by examining in each prepare call which file descriptors need to be watched by the other library, registering ev_io watchers for them and starting an ev_timer watcher for any timeouts (many libraries provide exactly this functionality). Then, in the check watcher, you check for any events that occurred (by checking the pending status of all watchers and stopping them) and call back into the library. The I/O and timer callbacks will never actually be called (but must be valid nevertheless, because you never know, you know?).
这是通过检查在每一个prepare调用中文件描述符需要被别的程序库监控，为它们注册ev_io watchers ，为了任何的超时，启动一个ev_timer watcher（很多程序库都提供这些功能）。那么，在check watcher中，你检查任何发生的事件（通过检查所有watchers的未处理状态并且停止它们）并且回调到程序库中。IO和定时器事件将事实上永远不会被调用（但是尽管如此，io和timer必须是有效的，因为你永远不知道，你懂的）。

As another example, the Perl Coro module uses these hooks to integrate coroutines into libev programs, by yielding to other active coroutines during each prepare and only letting the process block if no coroutines are ready to run (it's actually more complicated: it only runs coroutines with priority higher than or equal to the event loop and one coroutine of lower priority, but only once, using idle watchers to keep the event loop from blocking if lower-priority coroutines are active, thus mapping low-priority coroutines to idle/background tasks).
另外一个例子，Perl的coro模块使用钩子来继承协程到libev程序中，通过依从另外的活跃协程在每次prepare和如果没有协程准备运行，只让进程阻塞。（这实际上更加复杂：它只能运行协同程序优先高于或等于事件循环和低优先级中的一个协同程序，但仅仅一次，如果低优先级的协程是活跃的，那么使用idle watchers来保证event loop阻塞，从而映射优先级低的协程为空闲/后台任务）。

When used for this purpose, it is recommended to give ev_check watchers highest (EV_MAXPRI) priority, to ensure that they are being run before any other watchers after the poll (this doesn't matter for ev_prepare watchers).
当用来作为这个目的的时候，建议给ev_check watchers最好的优先级（EV_MAXPRI），来确保他们在任何另外的watchers之前和poll之后运行（对于ev_prepare watchers来说无关紧要）。

Also, ev_check watchers (and ev_prepare watchers, too) should not activate ("feed") events into libev. While libev fully supports this, they might get executed before other ev_check watchers did their job. As ev_check watchers are often used to embed other (non-libev) event loops those other event loops might be in an unusable state until their ev_check watcher ran (always remind yourself to coexist peacefully with others).
此外，ev_check watchers（ev_prepare watchers也是如此）应该不会激活事件到libev中，尽管libev完全支持这个功能，他们可能在另外的ev_check watchers被调用之前执行。由于ev_check watchers经常被用来嵌入另外（非libev）的event loop，另外的event loops可能在一个不稳定的状态，知道他们的ev_check watcer运行（总是提醒你自己与他人和平相处）。

Abusing an ev_check watcher for its side-effect
ec_check被滥用的副作用

ev_check (and less often also ev_prepare) watchers can also be useful because they are called once per event loop iteration. For example, if you want to handle a large number of connections fairly, you normally only do a bit of work for each active connection, and if there is more work to do, you wait for the next event loop iteration, so other connections have a chance of making progress.
ev_check（往往还有ev_prepare）watchers是有用的，因为它们在每次的event loop迭代中都会被调用一次。例如，如果你想公平的处理大量的连接，你通常每个连接只能做一点事情，如果你有更多的事情要做，你必须等待下一次的迭代，所以另外的连接有取得处理的机会。

Using an ev_check watcher is almost enough: it will be called on the next event loop iteration. However, that isn't as soon as possible - without external events, your ev_check watcher will not be invoked.
使用一个ev_check watcher是不够的：它将会在下一次的event loop迭代中被调用。然而，这不是尽可能的-如果没有外部事件，你的ev_check watcher将不会被调用。

This is where ev_idle watchers come in handy - all you need is a single global idle watcher that is active as long as you have one active ev_check watcher. The ev_idle watcher makes sure the event loop will not sleep, and the ev_check watcher makes sure a callback gets invoked. Neither watcher alone can do that.
这个时候ev_idle watcher就会派上用场了-，只要你有一个活跃的ev_check，你就需要的是一个全局的活跃的idle watcher。ev_idle watcher确保event loop不需要休眠，ev_check watcher确保函数被调用，任何一个单独的watcher都不能做到这样。
PS：其实就是说使用ev_idle watcher来带动event loop迭代，从而唤醒ev_prepare和ev_check。

Watcher-Specific Functions and Data Members

ev_prepare_init (ev_prepare *, callback)
ev_check_init (ev_check *, callback)
Initialises and configures the prepare or check watcher - they have no parameters of any kind. There are ev_prepare_set and ev_check_set macros, but using them is utterly, utterly, utterly and completely pointless.
初始化和配置prepare和check watcher-他们没有任何类型的参数。它们只是ev_prepare_set和ev_check_set宏，但是使用他们是完全完全完全没有意义的。

Examples

There are a number of principal ways to embed other event loops or modules into libev. Here are some ideas on how to include libadns into libev (there is a Perl module named EV::ADNS that does this, which you could use as a working example. Another Perl module named EV::Glib embeds a Glib main context into libev, and finally, Glib::EV embeds EV into the Glib event loop).
有一些嵌入另外的event loops或者模块到libev的主要方法。下面是一些关于怎么把libadns嵌入到libev的方法（perl的EV::ADNS模块就是这么做的，你可以使用它作为一个可以工作的示例。另外一个perl的EV:Glib模块把一个Glib的主要上下文嵌入到libev，最后，Glib::EV嵌入EV到Glib的event loop）。


Method 1: Add IO watchers and a timeout watcher in a prepare handler, and in a check watcher, destroy them and call into libadns. What follows is pseudo-code only of course. This requires you to either use a low priority for the check watcher or use ev_clear_pending explicitly, as the callbacks for the IO/timeout watchers might not have been called yet.
方法1：在一个prepare处理事件中加一个IO watcher和timeout watcher，并且在check watcher，释放他们并且调用libadns。下面当然是伪代码，这需要你要么使用一个低优先级的check watcher或者明确使用ev_clear_pending，作为IO/timeout watchers的回调可能不会被调用。

static ev_io iow [nfd];
static ev_timer tw;

static void
io_cb (struct ev_loop *loop, ev_io *w, int revents)
{
}

// create io watchers for each fd and a timer before blocking
static void
adns_prepare_cb (struct ev_loop *loop, ev_prepare *w, int revents)
{
int timeout = 3600000;
struct pollfd fds [nfd];
// actual code will need to loop here and realloc etc.
adns_beforepoll (ads, fds, &nfd, &timeout, timeval_from (ev_time ()));

/* the callback is illegal, but won't be called as we stop during check */
ev_timer_init (&tw, 0, timeout * 1e-3, 0.);
ev_timer_start (loop, &tw);

// create one ev_io per pollfd
for (int i = 0; i < nfd; ++i)
{
ev_io_init (iow + i, io_cb, fds [i].fd,
((fds [i].events & POLLIN ? EV_READ : 0)
| (fds [i].events & POLLOUT ? EV_WRITE : 0)));

fds [i].revents = 0;
ev_io_start (loop, iow + i);
}
}

// stop all watchers after blocking
static void
adns_check_cb (struct ev_loop *loop, ev_check *w, int revents)
{
ev_timer_stop (loop, &tw);

for (int i = 0; i < nfd; ++i)
{
// set the relevant poll flags
// could also call adns_processreadable etc. here
struct pollfd *fd = fds + i;
int revents = ev_clear_pending (iow + i);
if (revents & EV_READ ) fd->revents |= fd->events & POLLIN;
if (revents & EV_WRITE) fd->revents |= fd->events & POLLOUT;

// now stop the watcher
ev_io_stop (loop, iow + i);
}

adns_afterpoll (adns, fds, nfd, timeval_from (ev_now (loop));
}

Method 2: This would be just like method 1, but you run adns_afterpoll in the prepare watcher and would dispose of the check watcher.
方法2：和方法i差不多，但是在prepare watcher中运行adns_afterpoll，并且处理check watcher。

Method 3: If the module to be embedded supports explicit event notification (libadns does), you can also make use of the actual watcher callbacks, and only destroy/create the watchers in the prepare watcher.
方法3：如果模块被嵌入需要提供显式的通知（libadns就这样做的），你也可以利用实际watcher的回调，并且只在prepare watcher中释放/创建watchers。

static void
timer_cb (EV_P_ ev_timer *w, int revents)
{
adns_state ads = (adns_state)w->data;
update_now (EV_A);

adns_processtimeouts (ads, &tv_now);
}

static void
io_cb (EV_P_ ev_io *w, int revents)
{
adns_state ads = (adns_state)w->data;
update_now (EV_A);

if (revents & EV_READ ) adns_processreadable  (ads, w->fd, &tv_now);
if (revents & EV_WRITE) adns_processwriteable (ads, w->fd, &tv_now);
}

// do not ever call adns_afterpoll

Method 4: Do not use a prepare or check watcher because the module you want to embed is not flexible enough to support it. Instead, you can override their poll function. The drawback with this solution is that the main loop is now no longer controllable by EV. The Glib::EV module uses this approach, effectively embedding EV as a client into the horrible libglib event loop.
方法2：不使用prepare或者check watcher，因为你想嵌入的模块不够灵活的支持他。相反，你可以重写你的poll函数。这种解决方案的缺点是，主loop不能通过EV控制。Glib::EV模块使用这种方法，当客户端进入libglib event loop是，有效的嵌入EV。

static gint
event_poll_func (GPollFD *fds, guint nfds, gint timeout)
{
int got_events = 0;

for (n = 0; n < nfds; ++n)
// create/start io watcher that sets the relevant bits in fds[n] and increment got_events

if (timeout >= 0)
// create/start timer

// poll
ev_run (EV_A_ 0);

// stop timer again
if (timeout >= 0)
ev_timer_stop (EV_A_ &to);

// stop io watchers again - their callbacks should have set
for (n = 0; n < nfds; ++n)
ev_io_stop (EV_A_ iow [n]);

return got_events;
}

ev_embed - when one backend isn't enough…
ev_embed-当一个后台不够用的时候

This is a rather advanced watcher type that lets you embed one event loop into another (currently only ev_io events are supported in the embedded loop, other types of watchers might be handled in a delayed or incorrect fashion and must not be used).
这是一个相当高级的watcher类型，让你可以把一个event loop嵌入到另外一个event loop中（当前，在嵌入的loop中只有ev_io events是获得支持的，别的类型的watchers可能会被延迟处理或者出错，所以不能使用）。

There are primarily two reasons you would want that: work around bugs and prioritise I/O.
使用ev_embed的原因主要有2个：解决bug和优先级IO。

As an example for a bug workaround, the kqueue backend might only support sockets on some platform, so it is unusable as generic backend, but you still want to make use of it because you have many sockets and it scales so nicely. In this case, you would create a kqueue-based loop and embed it into your default loop (which might use e.g. poll). Overall operation will be a bit slower because first libev has to call poll and then kevent, but at least you can use both mechanisms for what they are best: kqueue for scalable sockets and poll if you want it to work :)
作为一个解决bug的例子，在一些平台上，kqueue只支持sockets，所以它并不是一个通用的后台，但是你仍然想要使用它，因为你有很多的socket要处理并且kqueue处理的很好。在这种情况下，你可以创建一个基于kqueue的loop并且把它嵌入你的默认的loop（默认的loop可能是基于poll的）。总体的操作可能会有一点慢，因为首先libev要调用poll然后才是kevent（应该是queuue的事件吧），但是，至少你可以同时使用2个合适的机制：kqueue处理socket，poll处理你想要它做的事情）。

As for prioritising I/O: under rare circumstances you have the case where some fds have to be watched and handled very quickly (with low latency), and even priorities and idle watchers might have too much overhead. In this case you would put all the high priority stuff in one loop and all the rest in a second one, and embed the second one in the first.
至于考虑到优先级的IO：在极少数情况下，你可能介意一些fds被监控和快速的被处理（低延迟的），优先级和idle watchers也可能会有更多的开销。在这种情况下，你可以把一些高优先级的事情放到一个loop中，剩下的放到第二个loop中，然后把第二个嵌入到第一个。

As long as the watcher is active, the callback will be invoked every time there might be events pending in the embedded loop. The callback must then call ev_embed_sweep (mainloop, watcher) to make a single sweep and invoke their callbacks (the callback doesn't need to invoke the ev_embed_sweep function directly, it could also start an idle watcher to give the embedded loop strictly lower priority for example).
只要watcher是活跃的，回调将每次都会被调用，这可能是嵌入loop中的未处理事件。回调必须调用ev_embed_sweep（mainloop，watcher）来做一次扫描并且调用它们的回调（回调不需要立即调用ev_embed_sweep函数，它也可以启动一个idle watcher来给嵌入的loop严格的低优先级）。

You can also set the callback to 0, in which case the embed watcher will automatically execute the embedded loop sweep whenever necessary.
你也可以把回调设置成0，这种情况下，embed watcher将会在有必要的情况下自动的执行被嵌入loop的扫描。

Fork detection will be handled transparently while the ev_embed watcher is active, i.e., the embedded loop will automatically be forked when the embedding loop forks. In other cases, the user is responsible for calling ev_loop_fork on the embedded loop.
当ev_embed watcher是活跃状态的时候，fork检测将会被透明的处理，即当被嵌入的loop fork时，被嵌入loop将自动的forked。另外一种情况，用户自己负责在被嵌入的loop上调用ev_loop_fork。

Unfortunately, not all backends are embeddable: only the ones returned by ev_embeddable_backends are, which, unfortunately, does not include any portable one.
不幸的时，不是所有的后台都可以被嵌入：只有ev_embeddable_backends返回的才可以，这很不幸，不能包括任意的。

So when you want to use this feature you will always have to be prepared that you cannot get an embeddable loop. The recommended way to get around this is to have a separate variables for your embeddable loop, try to create it, and if that fails, use the normal loop for everything.
所以当你使用这个功能的时候你得有心理准备：你不能得到一个可以被嵌入的loop。解决这个问题推荐的方法是有一个变量来保存你的被嵌入的loop，试着创建它，如果失败，那么就使用默认的loop。

ev_embed and fork

While the ev_embed watcher is running, forks in the embedding loop will automatically be applied to the embedded loop as well, so no special fork handling is required in that case. When the watcher is not running, however, it is still the task of the libev user to call ev_loop_fork () as applicable.
当ev_embed watcher运行的时候，在被嵌入的loop中forks将会自动的被很好的应用在被嵌入的loop中，所以在这种情况下，不需要特殊的fork来处理。当watcher不在运行的时候，不管怎么样，它仍然是libev用户的任务来调用ev_loop_fork（）。

Watcher-Specific Functions and Data Members

ev_embed_init (ev_embed *, callback, struct ev_loop *embedded_loop)
ev_embed_set (ev_embed *, struct ev_loop *embedded_loop)
Configures the watcher to embed the given loop, which must be embeddable. If the callback is 0, then ev_embed_sweep will be invoked automatically, otherwise it is the responsibility of the callback to invoke it (it will continue to be called until the sweep has been done, if you do not want that, you need to temporarily stop the embed watcher).
配置watcher来嵌入到给定的loop，loop必须是被嵌入的。如果回调是0，那么ev_embed_sweep将会自动调用，否则调用的它的责任将是回调的（它将仍然被调用知道扫描被完成，如果你不想这样，你需要暂停被嵌入watcher）。

ev_embed_sweep (loop, ev_embed *)
Make a single, non-blocking sweep over the embedded loop. This works similarly to ev_run (embedded_loop, EVRUN_NOWAIT), but in the most appropriate way for embedded loops.
在被嵌入的loop上做一个单一的，非阻塞的扫描。这个工作类似于ev_run（evbedded_loop，EVRUN_NOWAIT），但是是被嵌入loop最合适的方法。

struct ev_loop *other [read-only]
The embedded event loop.

Examples

Example: Try to get an embeddable event loop and embed it into the default event loop. If that is not possible, use the default loop. The default loop is stored in loop_hi, while the embeddable loop is stored in loop_lo (which is loop_hi in the case no embeddable loop can be used).
例子：试着得到一个被嵌入的event loop，并且嵌入它到默认的loop。如果这是不可能的，那就使用默认的loop。默认的loop被保存在loop_hi，而可以嵌入的loop保存在loop_lo（也就是loop_hi在没有嵌入的循环可以使用的情况下）。

struct ev_loop *loop_hi = ev_default_init (0);
struct ev_loop *loop_lo = 0;
ev_embed embed;

// see if there is a chance of getting one that works
//看看是否有可以得到工作的机会
// (remember that a flags value of 0 means autodetection)
//记住0表示自动检测
loop_lo = ev_embeddable_backends () & ev_recommended_backends ()
? ev_loop_new (ev_embeddable_backends () & ev_recommended_backends ())
: 0;

// if we got one, then embed it, otherwise default to loop_hi
//如果得到一个，就嵌入它，否则就使用默认的。
if (loop_lo)
{
ev_embed_init (&embed, 0, loop_lo);
ev_embed_start (loop_hi, &embed);
}
else
loop_lo = loop_hi;

Example: Check if kqueue is available but not recommended and create a kqueue backend for use with sockets (which usually work with any kqueue implementation). Store the kqueue/socket-only event loop in loop_socket. (One might optionally use EVFLAG_NOENV, too).
例子：检查kqueue是否可用，但是不建议创建一个kqueue后台来给socket使用（这通常适用于任何kqueue实现）。保存kqueue/socket-only event loop在loop——socket中。（也有人可能会选择使用EVFLAG_NOENV）。

struct ev_loop *loop = ev_default_init (0);
struct ev_loop *loop_socket = 0;
ev_embed embed;

if (ev_supported_backends () & ~ev_recommended_backends () & EVBACKEND_KQUEUE)
if ((loop_socket = ev_loop_new (EVBACKEND_KQUEUE))
{
ev_embed_init (&embed, 0, loop_socket);
ev_embed_start (loop, &embed);
}

if (!loop_socket)
loop_socket = loop;

// now use loop_socket for all sockets, and loop for everything else

ev_fork - the audacity to resume the event loop after a fork
ev_fork 在fork之后强制恢复event loop

Fork watchers are called when a fork () was detected (usually because whoever is a good citizen cared to tell libev about it by calling ev_loop_fork). The invocation is done before the event loop blocks next and before ev_check watchers are being called, and only in the child after the fork. If whoever good citizen calling ev_default_fork cheats and calls it in the wrong process, the fork handlers will be invoked, too, of course.
当fork函数被检测到时，fork watcher被调用（通常因为不会在意是那个成员告诉了libev：它调用了ev_loop_fork）。这个调用将在下一次的event loop阻塞之前和ev_check watcher被调用之前，并且只在fork之后的子进程中被调用。不管那个成员在错误的进程中调用ev_default_fork欺骗和调用它，fork处理事件当然也会被调用。

The special problem of life after fork - how is it possible?
fork之后生命周期特殊的问题-有哪些可能？

Most uses of fork () consist of forking, then some simple calls to set up/change the process environment, followed by a call to exec(). This sequence should be handled by libev without any problems.
大多数使用fork来创建新进程，然后简单的调用一些设置或者改变进程环境，比如接着调用exec函数。这一序列将毫无疑问的被libev处理。

This changes when the application actually wants to do event handling in the child, or both parent in child, in effect "continuing" after the fork.
这会在应用程序实际上想在子进程或者父子进程中执行事件处理函数的时候改变，实际上是在fork之后继续。

The default mode of operation (for libev, with application help to detect forks) is to duplicate all the state in the child, as would be expected when either the parent or the child process continues.
缺省的操作模式（对于libev来说，应用程序期望检测到forks）是在子进程中复制所有的状态，不管是对于父进程还是子进程来说，都是希望能一如既往。

When both processes want to continue using libev, then this is usually the wrong result. In that case, usually one process (typically the parent) is supposed to continue with all watchers in place as before, while the other process typically wants to start fresh, i.e. without any active watchers.
当父子进程都希望继续使用libev，那么这通常都是错误的。在这种情况下，通常一个进程（通常是父进程）还是会和以前一样带着所有的watchers继续执行，同时，另外一个进程执行新的libev，即没有任何活跃的watchers。

The cleanest and most efficient way to achieve that with libev is to simply create a new event loop, which of course will be "empty", and use that for new watchers. This has the advantage of not touching more memory than necessary, and thus avoiding the copy-on-write, and the disadvantage of having to use multiple event loops (which do not support signal watchers).
最简洁和最高效的实现方式是使用libev创建一个新的event loop，新的event loop当然就是”空“的了，并且用新的event loop监听新的watchers。这避免了很多的无必要的内存接触，从而避免了内存的写时复制，并且避免了使用多个event loop的缺点（多个event loop不能对信号watchers提供支持）。


When this is not possible, or you want to use the default loop for other reasons, then in the process that wants to start "fresh", call ev_loop_destroy (EV_DEFAULT) followed by ev_default_loop (...). Destroying the default loop will "orphan" (not stop) all registered watchers, so you have to be careful not to execute code that modifies those watchers. Note also that in that case, you have to re-register any signal watchers.
当这是不可能或者你想要为了别的原因使用默认的loop，比如在进程中以“新鲜”开始，那额在ev_default_loop()之后调用ev_loop_destry。释放默认的loop将“孤立”（而不是停止）所有已注册的watchers，所以你必须小心不要执行源码更改别的watchers。也要注意，在这种情况下，你必须重新注册所有的signal watchers。

Watcher-Specific Functions and Data Members

ev_fork_init (ev_fork *, callback)
Initialises and configures the fork watcher - it has no parameters of any kind. There is a ev_fork_set macro, but using it is utterly pointless, really.
初始化和配置fork watcher-它没有任何类型的参数。这就是一个ev_fork_set宏，但是使用它是毫无意义的，真的。

ev_cleanup - even the best things end
ev_cleanup-在即使最好的东西也结束的时候

Cleanup watchers are called just before the event loop is being destroyed by a call to ev_loop_destroy.
cleanup watchers将只会在event loop被ev_loop_destroy函数destroy之前被调用。

While there is no guarantee that the event loop gets destroyed, cleanup watchers provide a convenient method to install cleanup hooks for your program, worker threads and so on - you just to make sure to destroy the loop when you want them to be invoked.
虽然这不能保证event loop被销毁，清理watchers的所有钩子程序，执行线程等等-你只要确认当你想他们被调用的时候销毁loop。

Cleanup watchers are invoked in the same way as any other watcher. Unlike all other watchers, they do not keep a reference to the event loop (which makes a lot of sense if you think about it). Like all other watchers, you can call libev functions in the callback, except ev_cleanup_start.
cleanup wathers和别的watchers使用同样的方法被调用。但是不想另外所有的watchers，他们不会维持和event loop的引用（比如你思考这个问题，它会有很多的意义）。和别的所有的watchers一样，你可以在回调函数中调用libev函数，除了ev_cleanup_start函数之外。

Watcher-Specific Functions and Data Members

ev_cleanup_init (ev_cleanup *, callback)
Initialises and configures the cleanup watcher - it has no parameters of any kind. There is a ev_cleanup_set macro, but using it is utterly pointless, I assure you.
初始化和配置cleanup watcher-他没有任何类型的参数。这就是一个ev_cleanup_set宏，但是使用它没有意义，我向你保证。

Example: Register an atexit handler to destroy the default loop, so any cleanup functions are called.
示例：注册一个atexit处理事件来释放默认的loop，所以任何清理函数被调用。

static void
program_exits (void)
{
ev_loop_destroy (EV_DEFAULT_UC);
}

...
atexit (program_exits);

ev_async - how to wake up an event loop
ev_async -怎么唤醒一个event loop

In general, you cannot use an ev_loop from multiple threads or other asynchronous sources such as signal handlers (as opposed to multiple event loops - those are of course safe to use in different threads).
一般情况下，你不能在多线程或者另外的比如类似于信号事件的异步来源中使用一个ev_loop（在不同的线程中使用不同的event loop，这当然是线程安全的）。

Sometimes, however, you need to wake up an event loop you do not control, for example because it belongs to another thread. This is what ev_async watchers do: as long as the ev_async watcher is active, you can signal it by calling ev_async_send, which is thread- and signal safe.
有的时候，不管怎么样，你需要唤醒一个你不能控制的event loop，例如这个event loop属于另外一个线程。这就是ev_sync watcher所能做的：只要ev_async watcher是可用的，你就可以通过调用ev_async_end来唤醒它，并且这是线程和信号安全的。

This functionality is very similar to ev_signal watchers, as signals, too, are asynchronous in nature, and signals, too, will be compressed (i.e. the number of callback invocations may be less than the number of ev_async_send calls). In fact, you could use signal watchers as a kind of "global async watchers" by using a watcher on an otherwise unused signal, and ev_feed_signal to signal this watcher from another thread, even without knowing which loop owns the signal.
当处理信号的时候，这个功能非常类似于ev_signal watchers，也有非同步的性质，也会被压缩（即：调用回调的次数可能会少于调用ev_async_send的次数）。事实上，你可以通过在另外一个没有使用的信号上使用一个watcher，来使该signal watcher作为一种全局的异步watchers，然后在另外一个线程中调用ev_feed_signal来唤醒它，即使你不知道哪个looo拥有这个信号。

Queueing

ev_async does not support queueing of data in any way. The reason is that the author does not know of a simple (or any) algorithm for a multiple-writer-single-reader queue that works in all cases and doesn't need elaborate support such as pthreads or unportable memory access semantics.
ev_async没有提供任何方式的队列。原因就是作者不知道适应任何情况下的，一个简单的算法来实现多写单读的队列，并且也不需要复杂的提供例如pthread或者不可移植的访问内存语义。

That means that if you want to queue data, you have to provide your own queue. But at least I can tell you how to implement locking around your queue:
这就意味着，如果你想排列你的数据，你必须提供你自己的队列。但是至少，我可以告诉你怎么实现你的队列锁。

queueing from a signal handler context
排列一个信号处理事件上下文
To implement race-free queueing, you simply add to the queue in the signal handler but you block the signal handler in the watcher callback. Here is an example that does that for some fictitious SIGUSR1 handler:
实现一个自由队列，在信号处理函数中加入到队列，在watcher callback中阻塞你的程序，这是一个例子：对SIGUSR1处理函数排队。


static ev_async mysig;

static void
sigusr1_handler (void)
{
sometype data;

// no locking etc.
queue_put (data);
ev_async_send (EV_DEFAULT_ &mysig);
}

static void
mysig_cb (EV_P_ ev_async *w, int revents)
{
sometype data;
sigset_t block, prev;

sigemptyset (&block);
sigaddset (&block, SIGUSR1);
sigprocmask (SIG_BLOCK, &block, &prev);

while (queue_get (&data))
process (data);

if (sigismember (&prev, SIGUSR1)
sigprocmask (SIG_UNBLOCK, &block, 0);
}

(Note: pthreads in theory requires you to use pthread_setmask instead of sigprocmask when you use threads, but libev doesn't do it either…).
（注意：理论上，当你使用pthreads时，pthread需要使用pthread_setmask来代替sigprocmask，但是libev需要这样做，所以。。。。）。

queueing from a thread context
一个线程上下文中排序
The strategy for threads is different, as you cannot (easily) block threads but you can easily preempt them, so to queue safely you need to employ a traditional mutex lock, such as in this pthread example:
对于线程，方法是不一样的，因为你不能（轻易）的阻塞线程，但是你可以轻易的抢占他们，所以你需要一个传统的mutex锁，以便排队数据，就像在这个示例一样。

static ev_async mysig;
static pthread_mutex_t mymutex = PTHREAD_MUTEX_INITIALIZER;

static void
otherthread (void)
{
// only need to lock the actual queueing operation
pthread_mutex_lock (&mymutex);
queue_put (data);
pthread_mutex_unlock (&mymutex);

ev_async_send (EV_DEFAULT_ &mysig);
}

static void
mysig_cb (EV_P_ ev_async *w, int revents)
{
pthread_mutex_lock (&mymutex);

while (queue_get (&data))
process (data);

pthread_mutex_unlock (&mymutex);
}

Watcher-Specific Functions and Data Members

ev_async_init (ev_async *, callback)
Initialises and configures the async watcher - it has no parameters of any kind. There is a ev_async_set macro, but using it is utterly pointless, trust me.
初始化和配置async watcher-它没有任何类型的参数。其实就是一个ev_asynv_set宏，但是使用这个宏是没有意义的，相信我。

ev_async_send (loop, ev_async *)
Sends/signals/activates the given ev_async watcher, that is, feeds an EV_ASYNC event on the watcher into the event loop, and instantly returns.
发送/触发/激活给定的ev_async watcher。即发送一个EV_ASYNC事件到event loop中的watcher，然后立即返回。

Unlike ev_feed_event, this call is safe to do from other threads, signal or similar contexts (see the discussion of EV_ATOMIC_T in the embedding section below on what exactly this means).
不像ev_feed_event，从另外的线程中，信号或者类似的环境中调用这个函数是线程安全的（请查阅下面的EV_ATOMIC_T的嵌入部分）。

Note that, as with other watchers in libev, multiple events might get compressed into a single callback invocation (another way to look at this is that ev_async watchers are level-triggered: they are set on ev_async_send, reset when the event loop detects that).
注意：和另外的libev中的watcher一样，多个事件可能会被合并成到一个回调中调用（理解这个问题的另外一种是把ev_async看成是水平触发的（PS：结合epoll，kqueue这种理解）：他们在ev_async_send时被触发，并且在event loop检测时被复位）。

This call incurs the overhead of at most one extra system call per event loop iteration, if the event loop is blocked, and no syscall at all if the event loop (or your program) is processing events. That means that repeated calls are basically free (there is no need to avoid calls for performance reasons) and that the overhead becomes smaller (typically zero) under load.
这个函数调用最多在每次event loop迭代中在开始引起一个额外的系统调用，如果event loop是被阻塞的，而且如果event loop（或者你的程序）根本没有系统调用处理事件。这意味着重复调用基本上不消耗资源（没有必要为了性能原因限制调用）并且负债开销也会变小（通常为0）。

bool = ev_async_pending (ev_async *)
Returns a non-zero value when ev_async_send has been called on the watcher but the event has not yet been processed (or even noted) by the event loop.
返回非0值意味着给定watcher的ev_async_send被调用，但是事件并没有被event loop处理完成。

ev_async_send sets a flag in the watcher and wakes up the loop. When the loop iterates next and checks for the watcher to have become active, it will reset the flag again. ev_async_pending can be used to very quickly check whether invoking the loop might be a good idea.
ev_async_send在watcher上设置一个标志并且唤醒loop。当下一次loop迭代并且检查watcher使其变成活跃时，他将会再一次重置他的状态。ev_async_pending可以被当作一个好的方法用来快速的检查是否调用loop。

Not that this does not check whether the watcher itself is pending, only whether it has been requested to make this watcher pending: there is a time window between the event loop checking and resetting the async notification, and the callback being invoked.
不是说这不能检查watcher本身是否被挂起，只是检查他是否被请求使这个watcher挂起：这是一个在event loop检查并且重置async通知和回调函数被调用之间的时间窗口，

OTHER FUNCTIONS

There are some other functions of possible interest. Described. Here. Now.
这里是一些你可能感兴趣的另外一个功能。

ev_once (loop, int fd, int events, ev_tstamp timeout, callback)
This function combines a simple timer and an I/O watcher, calls your callback on whichever event happens first and automatically stops both watchers. This is useful if you want to wait for a single event on an fd or timeout without having to allocate/configure/start/stop/free one or more watchers yourself.
这个函数合并了一个简单的timer watcher和一个IO watcher，哪个watcher先发生，就会自动停止两个watcher，并且调用你的回调函数。这对于你想在一个fd上等到一个IO事件或者超时事件而不用必须自己申请/配置/开始/停止/释放watcher是非常有用的，

If fd is less than 0, then no I/O watcher will be started and the events argument is being ignored. Otherwise, an ev_io watcher for the given fd and events set will be created and started.
如果fd小于0，那么将没有IO watcher被启动，并且这个参数将会被忽略。否则对于给定的fd将创建和启动ev_io watcher。

If timeout is less than 0, then no timeout watcher will be started. Otherwise an ev_timer watcher with after = timeout (and repeat = 0) will be started. 0 is a valid timeout.
如果timeout小于0，那么没有超时watcher将被启动。否则一个after＝timeout（和repeat ＝ 0）的ev_timer watcher将被启动。0是一个有效的超时。

The callback has the type void (*cb)(int revents, void *arg) and is passed an revents set like normal event callbacks (a combination of EV_ERROR, EV_READ, EV_WRITE or EV_TIMER) and the arg value passed to ev_once. Note that it is possible to receive both a timeout and an io event at the same time - you probably should give io events precedence.
回调函数的类型是void (*cb)(int revents, void *arg)，并且通过设置一个正确的revents（一个EV_ERROR，EV_READ，EV_WRITE或者EV_TIMER的组合），并且参数arg的值也会传递给ev）once。注意：可能会同时收到超时和IO event-你或许应该给io事件一个高优先级。

Example: wait up to ten seconds for data to appear on STDIN_FILENO.

static void stdin_ready (int revents, void *arg)
{
if (revents & EV_READ)
/* stdin might have data for us, joy! */;
else if (revents & EV_TIMER)
/* doh, nothing entered */;
}

ev_once (STDIN_FILENO, EV_READ, 10., stdin_ready, 0);

ev_feed_fd_event (loop, int fd, int revents)
Feed an event on the given fd, as if a file descriptor backend detected the given events.
向给定的fd发送一个事件，就好像文件描述符后台检测到事件一样。

ev_feed_signal_event (loop, int signum)
Feed an event as if the given signal occurred. See also ev_feed_signal, which is async-safe.
发送一个给定的信号。请查阅ev_feed_signal，这是异步安全的。

COMMON OR USEFUL IDIOMS (OR BOTH)
常见或者是习惯用法

This section explains some common idioms that are not immediately obvious. Note that examples are sprinkled over the whole manual, and this section only contains stuff that wouldn't fit anywhere else.
本节解释一些不常见的用法。注意：示例对于整个手册来说，本节只包含一些方法，但是不是任何地方都适用。

ASSOCIATING CUSTOM DATA WITH A WATCHER
watcher的自定义数据

Each watcher has, by default, a void *data member that you can read or modify at any time: libev will completely ignore it. This can be used to associate arbitrary data with your watcher. If you need more data and don't want to allocate memory separately and store a pointer to it in that data member, you can also "subclass" the watcher type and provide your own data:
每个watcher默认都有一个void *data成员，你可以在任何时候都读写这个成员：libev会完全忽略它。这可用于将任意数据与观察者相关联。如果您需要更多的数据，不希望单独分配内存和存储指向它的数据成员，也可以“继承”的watcher类型，并提供自己的数据：

struct my_io
{
ev_io io;
int otherfd;
void *somedata;
struct whatever *mostinteresting;
};

...
struct my_io w;
ev_io_init (&w.io, my_cb, fd, EV_READ);

And since your callback will be called with a pointer to the watcher, you can cast it back to your own type:
当你的回调被使用一个watcher指针调用时，你可以把它转换回你自己的类型。

static void my_cb (struct ev_loop *loop, ev_io *w_, int revents)
{
struct my_io *w = (struct my_io *)w_;
...
}

More interesting and less C-conformant ways of casting your callback function type instead have been omitted.
构造你回调函数类型的更有趣和更小的c一致性方法，而不是忽略它。

BUILDING YOUR OWN COMPOSITE WATCHERS
构造你自己的watchers组合

Another common scenario is to use some data structure with multiple embedded watchers, in effect creating your own watcher that combines multiple libev event sources into one “super-watcher":
另外一个常用的方法是使用多个嵌入式的watcher来构成数据结构，实际上就是创建你自己的watcher，它结合了很多libev事件源来组成一个“超级watcher”。

struct my_biggy
{
int some_data;
ev_timer t1;
ev_timer t2;
}

In this case getting the pointer to my_biggy is a bit more complicated: Either you store the address of your my_biggy struct in the data member of the watcher (for woozies or C++ coders), or you need to use some pointer arithmetic using offsetof inside your watchers (for real programmers):
这种情况下获取my_biggy的指针是比较麻烦的：一种方法就是在my_biggy的数据成员中保存一个指向my_biggy的地址，另外一个方法就是通过使用offsetof来计算my_biggy的地址（这是真正的程序员做的）。

#include <stddef.h>

static void
t1_cb (EV_P_ ev_timer *w, int revents)
{
struct my_biggy big = (struct my_biggy *)
(((char *)w) - offsetof (struct my_biggy, t1));
}

static void
t2_cb (EV_P_ ev_timer *w, int revents)
{
struct my_biggy big = (struct my_biggy *)
(((char *)w) - offsetof (struct my_biggy, t2));
}

AVOIDING FINISHING BEFORE RETURNING
在返回之前避免结束

Often you have structures like this in event-based programs:
通常在基于事件的程序中，你有这样的结构：

callback ()
{
free (request);
}

request = start_new_request (..., callback);

The intent is to start some "lengthy" operation. The request could be used to cancel the operation, or do other things with it.
这样做的目的是启动一些“冗长”的操作。这个请求可以用来取消操作，或者做另外的事情。

It's not uncommon to have code paths in start_new_request that immediately invoke the callback, for example, to report errors. Or you add some caching layer that finds that it can skip the lengthy aspects of the operation and simply invoke the callback with the result.
在start_new_request中有代码路径立即调用callback，这种情况并不少见。或者你增加一些缓存层来找到它可以跳过冗长的操作面，并且在结果中简单的调用callback。

The problem here is that this will happen before start_new_request has returned, so request is not set.
这里的问题是：这将会在start_ne_request返回之前发生，所以请求没有被设置。

Even if you pass the request by some safer means to the callback, you might want to do something to the request after starting it, such as canceling it, which probably isn't working so well when the callback has already been invoked.
即使你安全的传递访问给callback函数，你也想要在启动请求后给它做一些设置，比如取消它，当callback已经被调用额时候，这就可能不能很好的工作了。

A common way around all these issues is to make sure that start_new_request always returns before the callback is invoked. If start_new_request immediately knows the result, it can artificially delay invoking the callback by using a prepare or idle watcher for example, or more sneakily, by reusing an existing (stopped) watcher and pushing it into the pending queue:
围绕这些问题的常用方法是确保start_new_request总是返回的回调函数被调用之前。如果start_new_request立即知道结果，可以人为地通过prepare或者idle watcher来延迟调用回调，例如，以上悄悄，通过重新使用现有的（停止）watcher，将其推到未决队列：


ev_set_cb (watcher, callback);
ev_feed_event (EV_A_ watcher, 0);

This way, start_new_request can safely return before the callback is invoked, while not delaying callback invocation too much.
这种方法，start_new_request可以在callback被调用之前安全的返回。而不是拖延回调调用太多。

MODEL/NESTED EVENT LOOP INVOCATIONS AND EXIT CONDITIONS
模型/嵌套的event loop调用和退出条件

Often (especially in GUI toolkits) there are places where you have modal interaction, which is most easily implemented by recursively invoking ev_run.
通常（特别在GUI工具箱中），

This brings the problem of exiting - a callback might want to finish the main ev_run call, but not the nested one (e.g. user clicked "Quit", but a modal "Are you sure?" dialog is still waiting), or just the nested one and not the main one (e.g. user clocked "Ok" in a modal dialog), or some other combination: In these cases, a simple ev_break will not work.

The solution is to maintain "break this loop" variable for each ev_run invocation, and use a loop around ev_run until the condition is triggered, using EVRUN_ONCE:

// main loop
int exit_main_loop = 0;

while (!exit_main_loop)
ev_run (EV_DEFAULT_ EVRUN_ONCE);

// in a modal watcher
int exit_nested_loop = 0;

while (!exit_nested_loop)
ev_run (EV_A_ EVRUN_ONCE);

To exit from any of these loops, just set the corresponding exit variable:

// exit modal loop
exit_nested_loop = 1;

// exit main program, after modal loop is finished
exit_main_loop = 1;

// exit both
exit_main_loop = exit_nested_loop = 1;

THREAD LOCKING EXAMPLE

Here is a fictitious example of how to run an event loop in a different thread from where callbacks are being invoked and watchers are created/added/removed.

For a real-world example, see the EV::Loop::Async perl module, which uses exactly this technique (which is suited for many high-level languages).

The example uses a pthread mutex to protect the loop data, a condition variable to wait for callback invocations, an async watcher to notify the event loop thread and an unspecified mechanism to wake up the main thread.

First, you need to associate some data with the event loop:

typedef struct {
mutex_t lock; /* global loop lock */
ev_async async_w;
thread_t tid;
cond_t invoke_cv;
} userdata;

void prepare_loop (EV_P)
{
// for simplicity, we use a static userdata struct.
static userdata u;

ev_async_init (&u->async_w, async_cb);
ev_async_start (EV_A_ &u->async_w);

pthread_mutex_init (&u->lock, 0);
pthread_cond_init (&u->invoke_cv, 0);

// now associate this with the loop
ev_set_userdata (EV_A_ u);
ev_set_invoke_pending_cb (EV_A_ l_invoke);
ev_set_loop_release_cb (EV_A_ l_release, l_acquire);

// then create the thread running ev_run
pthread_create (&u->tid, 0, l_run, EV_A);
}

The callback for the ev_async watcher does nothing: the watcher is used solely to wake up the event loop so it takes notice of any new watchers that might have been added:

static void
async_cb (EV_P_ ev_async *w, int revents)
{
// just used for the side effects
}

The l_release and l_acquire callbacks simply unlock/lock the mutex protecting the loop data, respectively.

static void
l_release (EV_P)
{
userdata *u = ev_userdata (EV_A);
pthread_mutex_unlock (&u->lock);
}

static void
l_acquire (EV_P)
{
userdata *u = ev_userdata (EV_A);
pthread_mutex_lock (&u->lock);
}

The event loop thread first acquires the mutex, and then jumps straight into ev_run:

void *
l_run (void *thr_arg)
{
struct ev_loop *loop = (struct ev_loop *)thr_arg;

l_acquire (EV_A);
pthread_setcanceltype (PTHREAD_CANCEL_ASYNCHRONOUS, 0);
ev_run (EV_A_ 0);
l_release (EV_A);

return 0;
}

Instead of invoking all pending watchers, the l_invoke callback will signal the main thread via some unspecified mechanism (signals? pipe writes? Async::Interrupt?) and then waits until all pending watchers have been called (in a while loop because a) spurious wakeups are possible and b) skipping inter-thread-communication when there are no pending watchers is very beneficial):

static void
l_invoke (EV_P)
{
userdata *u = ev_userdata (EV_A);

while (ev_pending_count (EV_A))
{
wake_up_other_thread_in_some_magic_or_not_so_magic_way ();
pthread_cond_wait (&u->invoke_cv, &u->lock);
}
}

Now, whenever the main thread gets told to invoke pending watchers, it will grab the lock, call ev_invoke_pending and then signal the loop thread to continue:

static void
real_invoke_pending (EV_P)
{
userdata *u = ev_userdata (EV_A);

pthread_mutex_lock (&u->lock);
ev_invoke_pending (EV_A);
pthread_cond_signal (&u->invoke_cv);
pthread_mutex_unlock (&u->lock);
}

Whenever you want to start/stop a watcher or do other modifications to an event loop, you will now have to lock:

ev_timer timeout_watcher;
userdata *u = ev_userdata (EV_A);

ev_timer_init (&timeout_watcher, timeout_cb, 5.5, 0.);

pthread_mutex_lock (&u->lock);
ev_timer_start (EV_A_ &timeout_watcher);
ev_async_send (EV_A_ &u->async_w);
pthread_mutex_unlock (&u->lock);

Note that sending the ev_async watcher is required because otherwise an event loop currently blocking in the kernel will have no knowledge about the newly added timer. By waking up the loop it will pick up any new watchers in the next event loop iteration.

THREADS, COROUTINES, CONTINUATIONS, QUEUES... INSTEAD OF CALLBACKS

While the overhead of a callback that e.g. schedules a thread is small, it is still an overhead. If you embed libev, and your main usage is with some kind of threads or coroutines, you might want to customise libev so that doesn't need callbacks anymore.

Imagine you have coroutines that you can switch to using a function switch_to (coro), that libev runs in a coroutine called libev_coro and that due to some magic, the currently active coroutine is stored in a global called current_coro. Then you can build your own "wait for libev event" primitive by changing EV_CB_DECLARE and EV_CB_INVOKE (note the differing ; conventions):

#define EV_CB_DECLARE(type)   struct my_coro *cb;
#define EV_CB_INVOKE(watcher) switch_to ((watcher)->cb)

That means instead of having a C callback function, you store the coroutine to switch to in each watcher, and instead of having libev call your callback, you instead have it switch to that coroutine.

A coroutine might now wait for an event with a function called wait_for_event. (the watcher needs to be started, as always, but it doesn't matter when, or whether the watcher is active or not when this function is called):

void
wait_for_event (ev_watcher *w)
{
ev_set_cb (w, current_coro);
switch_to (libev_coro);
}

That basically suspends the coroutine inside wait_for_event and continues the libev coroutine, which, when appropriate, switches back to this or any other coroutine.

You can do similar tricks if you have, say, threads with an event queue - instead of storing a coroutine, you store the queue object and instead of switching to a coroutine, you push the watcher onto the queue and notify any waiters.

To embed libev, see EMBEDDING, but in short, it's easiest to create two files, my_ev.h and my_ev.c that include the respective libev files:

// my_ev.h
#define EV_CB_DECLARE(type)   struct my_coro *cb;
#define EV_CB_INVOKE(watcher) switch_to ((watcher)->cb);
#include "../libev/ev.h"

// my_ev.c
#define EV_H "my_ev.h"
#include "../libev/ev.c"

And then use my_ev.h when you would normally use ev.h, and compile my_ev.c into your project. When properly specifying include paths, you can even use ev.h as header file name directly.

LIBEVENT EMULATION

Libev offers a compatibility emulation layer for libevent. It cannot emulate the internals of libevent, so here are some usage hints:

* Only the libevent-1.4.1-beta API is being emulated.
    This was the newest libevent version available when libev was implemented, and is still mostly unchanged in 2010.

* Use it by including <event.h>, as usual.
* The following members are fully supported: ev_base, ev_callback, ev_arg, ev_fd, ev_res, ev_events.
* Avoid using ev_flags and the EVLIST_*-macros, while it is maintained by libev, it does not work exactly the same way as in libevent (consider it a private API).
* Priorities are not currently supported. Initialising priorities will fail and all watchers will have the same priority, even though there is an ev_pri field.
* In libevent, the last base created gets the signals, in libev, the base that registered the signal gets the signals.
* Other members are not supported.
* The libev emulation is not ABI compatible to libevent, you need to use the libev header file and library.
    C++ SUPPORT

    C API

    The normal C API should work fine when used from C++: both ev.h and the libev sources can be compiled as C++. Therefore, code that uses the C API will work fine.

    Proper exception specifications might have to be added to callbacks passed to libev: exceptions may be thrown only from watcher callbacks, all other callbacks (allocator, syserr, loop acquire/release and periodic reschedule callbacks) must not throw exceptions, and might need a throw () specification. If you have code that needs to be compiled as both C and C++ you can use the EV_THROW macro for this:

    static void
    fatal_error (const char *msg) EV_THROW
    {
    perror (msg);
    abort ();
    }

    ...
    ev_set_syserr_cb (fatal_error);

    The only API functions that can currently throw exceptions are ev_run, ev_invoke, ev_invoke_pending and ev_loop_destroy (the latter because it runs cleanup watchers).

    Throwing exceptions in watcher callbacks is only supported if libev itself is compiled with a C++ compiler or your C and C++ environments allow throwing exceptions through C libraries (most do).

    C++ API

    Libev comes with some simplistic wrapper classes for C++ that mainly allow you to use some convenience methods to start/stop watchers and also change the callback model to a model using method callbacks on objects.

    To use it,

#include <ev++.h>

This automatically includes ev.h and puts all of its definitions (many of them macros) into the global namespace. All C++ specific things are put into the ev namespace. It should support all the same embedding options as ev.h, most notably EV_MULTIPLICITY.

Care has been taken to keep the overhead low. The only data member the C++ classes add (compared to plain C-style watchers) is the event loop pointer that the watcher is associated with (or no additional members at all if you disable EV_MULTIPLICITY when embedding libev).

Currently, functions, static and non-static member functions and classes with operator () can be used as callbacks. Other types should be easy to add as long as they only need one additional pointer for context. If you need support for other types of functors please contact the author (preferably after implementing it).

For all this to work, your C++ compiler either has to use the same calling conventions as your C compiler (for static member functions), or you have to embed libev and compile libev itself as C++.

Here is a list of things available in the ev namespace:

ev::READ, ev::WRITE etc.
These are just enum values with the same values as the EV_READ etc. macros from ev.h.

ev::tstamp, ev::now
Aliases to the same types/functions as with the ev_ prefix.

ev::io, ev::timer, ev::periodic, ev::idle, ev::sig etc.
For each ev_TYPE watcher in ev.h there is a corresponding class of the same name in the ev namespace, with the exception of ev_signal which is called ev::sig to avoid clashes with the signal macro defined by many implementations.

All of those classes have these methods:

ev::TYPE::TYPE ()
ev::TYPE::TYPE (loop)
ev::TYPE::~TYPE
The constructor (optionally) takes an event loop to associate the watcher with. If it is omitted, it will use EV_DEFAULT.

The constructor calls ev_init for you, which means you have to call the set method before starting it.

It will not set a callback, however: You have to call the templated set method to set a callback before you can start the watcher.

(The reason why you have to use a method is a limitation in C++ which does not allow explicit template arguments for constructors).

The destructor automatically stops the watcher if it is active.

w->set<class, &class::method> (object *)
This method sets the callback method to call. The method has to have a signature of void (*)(ev_TYPE &, int), it receives the watcher as first argument and the revents as second. The object must be given as parameter and is stored in the data member of the watcher.

This method synthesizes efficient thunking code to call your method from the C callback that libev requires. If your compiler can inline your callback (i.e. it is visible to it at the place of the set call and your compiler is good :), then the method will be fully inlined into the thunking function, making it as fast as a direct C callback.

Example: simple class declaration and watcher initialisation

struct myclass
{
void io_cb (ev::io &w, int revents) { }
}

myclass obj;
ev::io iow;
iow.set <myclass, &myclass::io_cb> (&obj);

w->set (object *)
This is a variation of a method callback - leaving out the method to call will default the method to operator (), which makes it possible to use functor objects without having to manually specify the operator () all the time. Incidentally, you can then also leave out the template argument list.

The operator () method prototype must be void operator ()(watcher &w, int revents).

See the method-set above for more details.

Example: use a functor object as callback.

struct myfunctor
{
void operator() (ev::io &w, int revents)
{
...
}
}

myfunctor f;

ev::io w;
w.set (&f);

w->set<function> (void *data = 0)
Also sets a callback, but uses a static method or plain function as callback. The optional data argument will be stored in the watcher's data member and is free for you to use.

The prototype of the function must be void (*)(ev::TYPE &w, int).

See the method-set above for more details.

Example: Use a plain function as callback.

static void io_cb (ev::io &w, int revents) { }
iow.set <io_cb> ();

w->set (loop)
Associates a different struct ev_loop with this watcher. You can only do this when the watcher is inactive (and not pending either).

w->set ([arguments])
Basically the same as ev_TYPE_set (except for ev::embed watchers>), with the same arguments. Either this method or a suitable start method must be called at least once. Unlike the C counterpart, an active watcher gets automatically stopped and restarted when reconfiguring it with this method.

For ev::embed watchers this method is called set_embed, to avoid clashing with the set (loop) method.

w->start ()
Starts the watcher. Note that there is no loop argument, as the constructor already stores the event loop.

w->start ([arguments])
Instead of calling set and start methods separately, it is often convenient to wrap them in one call. Uses the same type of arguments as the configure set method of the watcher.

w->stop ()
Stops the watcher if it is active. Again, no loop argument.

w->again () (ev::timer, ev::periodic only)
For ev::timer and ev::periodic, this invokes the corresponding ev_TYPE_again function.

w->sweep () (ev::embed only)
Invokes ev_embed_sweep.

w->update () (ev::stat only)
Invokes ev_stat_stat.

Example: Define a class with two I/O and idle watchers, start the I/O watchers in the constructor.

class myclass
{
ev::io   io  ; void io_cb   (ev::io   &w, int revents);
ev::io   io2 ; void io2_cb  (ev::io   &w, int revents);
ev::idle idle; void idle_cb (ev::idle &w, int revents);

myclass (int fd)
{
io  .set <myclass, &myclass::io_cb  > (this);
io2 .set <myclass, &myclass::io2_cb > (this);
idle.set <myclass, &myclass::idle_cb> (this);

io.set (fd, ev::WRITE); // configure the watcher
io.start ();            // start it whenever convenient

io2.start (fd, ev::READ); // set + start in one call
}
};

OTHER LANGUAGE BINDINGS

Libev does not offer other language bindings itself, but bindings for a number of languages exist in the form of third-party packages. If you know any interesting language binding in addition to the ones listed here, drop me a note.

Perl
The EV module implements the full libev API and is actually used to test libev. EV is developed together with libev. Apart from the EV core module, there are additional modules that implement libev-compatible interfaces to libadns (EV::ADNS, but AnyEvent::DNS is preferred nowadays), Net::SNMP (Net::SNMP::EV) and the libglib event core (Glib::EV and EV::Glib).

It can be found and installed via CPAN, its homepage is at http://software.schmorp.de/pkg/EV.

Python
Python bindings can be found at http://code.google.com/p/pyev/. It seems to be quite complete and well-documented.

Ruby
Tony Arcieri has written a ruby extension that offers access to a subset of the libev API and adds file handle abstractions, asynchronous DNS and more on top of it. It can be found via gem servers. Its homepage is at http://rev.rubyforge.org/.

Roger Pack reports that using the link order -lws2_32 -lmsvcrt-ruby-190 makes rev work even on mingw.

Haskell
A haskell binding to libev is available at http://hackage.haskell.org/cgi-bin/hackage-scripts/package/hlibev.

D
Leandro Lucarella has written a D language binding (ev.d) for libev, to be found at http://www.llucax.com.ar/proj/ev.d/index.html.

Ocaml
Erkki Seppala has written Ocaml bindings for libev, to be found at http://modeemi.cs.tut.fi/~flux/software/ocaml-ev/.

Lua
Brian Maher has written a partial interface to libev for lua (at the time of this writing, only ev_io and ev_timer), to be found at http://github.com/brimworks/lua-ev.

Javascript
Node.js (http://nodejs.org) uses libev as the underlying event library.

Others
There are others, and I stopped counting.

MACRO MAGIC

Libev can be compiled with a variety of options, the most fundamental of which is EV_MULTIPLICITY. This option determines whether (most) functions and callbacks have an initial struct ev_loop * argument.

To make it easier to write programs that cope with either variant, the following macros are defined:

EV_A, EV_A_
This provides the loop argument for functions, if one is required ("ev loop argument"). The EV_A form is used when this is the sole argument, EV_A_ is used when other arguments are following. Example:

ev_unref (EV_A);
ev_timer_add (EV_A_ watcher);
ev_run (EV_A_ 0);

It assumes the variable loop of type struct ev_loop * is in scope, which is often provided by the following macro.

EV_P, EV_P_
This provides the loop parameter for functions, if one is required ("ev loop parameter"). The EV_P form is used when this is the sole parameter, EV_P_ is used when other parameters are following. Example:

// this is how ev_unref is being declared
static void ev_unref (EV_P);

// this is how you can declare your typical callback
static void cb (EV_P_ ev_timer *w, int revents)

It declares a parameter loop of type struct ev_loop *, quite suitable for use with EV_A.

EV_DEFAULT, EV_DEFAULT_
Similar to the other two macros, this gives you the value of the default loop, if multiple loops are supported ("ev loop default"). The default loop will be initialised if it isn't already initialised.

For non-multiplicity builds, these macros do nothing, so you always have to initialise the loop somewhere.

EV_DEFAULT_UC, EV_DEFAULT_UC_
Usage identical to EV_DEFAULT and EV_DEFAULT_, but requires that the default loop has been initialised (UC == unchecked). Their behaviour is undefined when the default loop has not been initialised by a previous execution of EV_DEFAULT, EV_DEFAULT_ or ev_default_init (...).

It is often prudent to use EV_DEFAULT when initialising the first watcher in a function but use EV_DEFAULT_UC afterwards.

Example: Declare and initialise a check watcher, utilising the above macros so it will work regardless of whether multiple loops are supported or not.

static void
check_cb (EV_P_ ev_timer *w, int revents)
{
ev_check_stop (EV_A_ w);
}

ev_check check;
ev_check_init (&check, check_cb);
ev_check_start (EV_DEFAULT_ &check);
ev_run (EV_DEFAULT_ 0);

EMBEDDING

Libev can (and often is) directly embedded into host applications. Examples of applications that embed it include the Deliantra Game Server, the EV perl module, the GNU Virtual Private Ethernet (gvpe) and rxvt-unicode.

The goal is to enable you to just copy the necessary files into your source directory without having to change even a single line in them, so you can easily upgrade by simply copying (or having a checked-out copy of libev somewhere in your source tree).

FILESETS

Depending on what features you need you need to include one or more sets of files in your application.

CORE EVENT LOOP

To include only the libev core (all the ev_* functions), with manual configuration (no autoconf):

#define EV_STANDALONE 1
#include "ev.c"

This will automatically include ev.h, too, and should be done in a single C source file only to provide the function implementations. To use it, do the same for ev.h in all files wishing to use this API (best done by writing a wrapper around ev.h that you can include instead and where you can put other configuration options):

#define EV_STANDALONE 1
#include "ev.h"

Both header files and implementation files can be compiled with a C++ compiler (at least, that's a stated goal, and breakage will be treated as a bug).

You need the following files in your source tree, or in a directory in your include path (e.g. in libev/ when using -Ilibev):

ev.h
ev.c
ev_vars.h
ev_wrap.h

ev_win32.c      required on win32 platforms only

ev_select.c     only when select backend is enabled (which is enabled by default)
ev_poll.c       only when poll backend is enabled (disabled by default)
ev_epoll.c      only when the epoll backend is enabled (disabled by default)
ev_kqueue.c     only when the kqueue backend is enabled (disabled by default)
ev_port.c       only when the solaris port backend is enabled (disabled by default)

ev.c includes the backend files directly when enabled, so you only need to compile this single file.

LIBEVENT COMPATIBILITY API

To include the libevent compatibility API, also include:

#include "event.c"

in the file including ev.c, and:

#include "event.h"

in the files that want to use the libevent API. This also includes ev.h.

You need the following additional files for this:

event.h
event.c

AUTOCONF SUPPORT

Instead of using EV_STANDALONE=1 and providing your configuration in whatever way you want, you can also m4_include([libev.m4]) in your configure.ac and leave EV_STANDALONE undefined. ev.c will then include config.h and configure itself accordingly.

For this of course you need the m4 file:

libev.m4

PREPROCESSOR SYMBOLS/MACROS

Libev can be configured via a variety of preprocessor symbols you have to define before including (or compiling) any of its files. The default in the absence of autoconf is documented for every option.

Symbols marked with "(h)" do not change the ABI, and can have different values when compiling libev vs. including ev.h, so it is permissible to redefine them before including ev.h without breaking compatibility to a compiled library. All other symbols change the ABI, which means all users of libev and the libev code itself must be compiled with compatible settings.

EV_COMPAT3 (h)
Backwards compatibility is a major concern for libev. This is why this release of libev comes with wrappers for the functions and symbols that have been renamed between libev version 3 and 4.

You can disable these wrappers (to test compatibility with future versions) by defining EV_COMPAT3 to 0 when compiling your sources. This has the additional advantage that you can drop the struct from struct ev_loop declarations, as libev will provide an ev_loop typedef in that case.

In some future version, the default for EV_COMPAT3 will become 0, and in some even more future version the compatibility code will be removed completely.

EV_STANDALONE (h)
Must always be 1 if you do not use autoconf configuration, which keeps libev from including config.h, and it also defines dummy implementations for some libevent functions (such as logging, which is not supported). It will also not define any of the structs usually found in event.h that are not directly supported by the libev core alone.

In standalone mode, libev will still try to automatically deduce the configuration, but has to be more conservative.

EV_USE_FLOOR
If defined to be 1, libev will use the floor () function for its periodic reschedule calculations, otherwise libev will fall back on a portable (slower) implementation. If you enable this, you usually have to link against libm or something equivalent. Enabling this when the floor function is not available will fail, so the safe default is to not enable this.

EV_USE_MONOTONIC
If defined to be 1, libev will try to detect the availability of the monotonic clock option at both compile time and runtime. Otherwise no use of the monotonic clock option will be attempted. If you enable this, you usually have to link against librt or something similar. Enabling it when the functionality isn't available is safe, though, although you have to make sure you link against any libraries where the clock_gettime function is hiding in (often -lrt). See also EV_USE_CLOCK_SYSCALL.

EV_USE_REALTIME
If defined to be 1, libev will try to detect the availability of the real-time clock option at compile time (and assume its availability at runtime if successful). Otherwise no use of the real-time clock option will be attempted. This effectively replaces gettimeofday by clock_get (CLOCK_REALTIME, ...) and will not normally affect correctness. See the note about libraries in the description of EV_USE_MONOTONIC, though. Defaults to the opposite value of EV_USE_CLOCK_SYSCALL.

EV_USE_CLOCK_SYSCALL
If defined to be 1, libev will try to use a direct syscall instead of calling the system-provided clock_gettime function. This option exists because on GNU/Linux, clock_gettime is in librt, but librt unconditionally pulls in libpthread, slowing down single-threaded programs needlessly. Using a direct syscall is slightly slower (in theory), because no optimised vdso implementation can be used, but avoids the pthread dependency. Defaults to 1 on GNU/Linux with glibc 2.x or higher, as it simplifies linking (no need for -lrt).

EV_USE_NANOSLEEP
If defined to be 1, libev will assume that nanosleep () is available and will use it for delays. Otherwise it will use select ().

EV_USE_EVENTFD
If defined to be 1, then libev will assume that eventfd () is available and will probe for kernel support at runtime. This will improve ev_signal and ev_async performance and reduce resource consumption. If undefined, it will be enabled if the headers indicate GNU/Linux + Glibc 2.7 or newer, otherwise disabled.

EV_USE_SELECT
If undefined or defined to be 1, libev will compile in support for the select(2) backend. No attempt at auto-detection will be done: if no other method takes over, select will be it. Otherwise the select backend will not be compiled in.

EV_SELECT_USE_FD_SET
If defined to 1, then the select backend will use the system fd_set structure. This is useful if libev doesn't compile due to a missing NFDBITS or fd_mask definition or it mis-guesses the bitset layout on exotic systems. This usually limits the range of file descriptors to some low limit such as 1024 or might have other limitations (winsocket only allows 64 sockets). The FD_SETSIZE macro, set before compilation, configures the maximum size of the fd_set.

EV_SELECT_IS_WINSOCKET
When defined to 1, the select backend will assume that select/socket/connect etc. don't understand file descriptors but wants osf handles on win32 (this is the case when the select to be used is the winsock select). This means that it will call _get_osfhandle on the fd to convert it to an OS handle. Otherwise, it is assumed that all these functions actually work on fds, even on win32. Should not be defined on non-win32 platforms.

EV_FD_TO_WIN32_HANDLE(fd)
If EV_SELECT_IS_WINSOCKET is enabled, then libev needs a way to map file descriptors to socket handles. When not defining this symbol (the default), then libev will call _get_osfhandle, which is usually correct. In some cases, programs use their own file descriptor management, in which case they can provide this function to map fds to socket handles.

EV_WIN32_HANDLE_TO_FD(handle)
If EV_SELECT_IS_WINSOCKET then libev maps handles to file descriptors using the standard _open_osfhandle function. For programs implementing their own fd to handle mapping, overwriting this function makes it easier to do so. This can be done by defining this macro to an appropriate value.

EV_WIN32_CLOSE_FD(fd)
If programs implement their own fd to handle mapping on win32, then this macro can be used to override the close function, useful to unregister file descriptors again. Note that the replacement function has to close the underlying OS handle.

EV_USE_WSASOCKET
If defined to be 1, libev will use WSASocket to create its internal communication socket, which works better in some environments. Otherwise, the normal socket function will be used, which works better in other environments.

EV_USE_POLL
If defined to be 1, libev will compile in support for the poll(2) backend. Otherwise it will be enabled on non-win32 platforms. It takes precedence over select.

EV_USE_EPOLL
If defined to be 1, libev will compile in support for the Linux epoll(7) backend. Its availability will be detected at runtime, otherwise another method will be used as fallback. This is the preferred backend for GNU/Linux systems. If undefined, it will be enabled if the headers indicate GNU/Linux + Glibc 2.4 or newer, otherwise disabled.

EV_USE_KQUEUE
If defined to be 1, libev will compile in support for the BSD style kqueue(2) backend. Its actual availability will be detected at runtime, otherwise another method will be used as fallback. This is the preferred backend for BSD and BSD-like systems, although on most BSDs kqueue only supports some types of fds correctly (the only platform we found that supports ptys for example was NetBSD), so kqueue might be compiled in, but not be used unless explicitly requested. The best way to use it is to find out whether kqueue supports your type of fd properly and use an embedded kqueue loop.

EV_USE_PORT
If defined to be 1, libev will compile in support for the Solaris 10 port style backend. Its availability will be detected at runtime, otherwise another method will be used as fallback. This is the preferred backend for Solaris 10 systems.

EV_USE_DEVPOLL
Reserved for future expansion, works like the USE symbols above.

EV_USE_INOTIFY
If defined to be 1, libev will compile in support for the Linux inotify interface to speed up ev_stat watchers. Its actual availability will be detected at runtime. If undefined, it will be enabled if the headers indicate GNU/Linux + Glibc 2.4 or newer, otherwise disabled.

EV_NO_SMP
If defined to be 1, libev will assume that memory is always coherent between threads, that is, threads can be used, but threads never run on different cpus (or different cpu cores). This reduces dependencies and makes libev faster.

EV_NO_THREADS
If defined to be 1, libev will assume that it will never be called from different threads (that includes signal handlers), which is a stronger assumption than EV_NO_SMP, above. This reduces dependencies and makes libev faster.

EV_ATOMIC_T
Libev requires an integer type (suitable for storing 0 or 1) whose access is atomic with respect to other threads or signal contexts. No such type is easily found in the C language, so you can provide your own type that you know is safe for your purposes. It is used both for signal handler "locking" as well as for signal and thread safety in ev_async watchers.

In the absence of this define, libev will use sig_atomic_t volatile (from signal.h), which is usually good enough on most platforms.

EV_H (h)
The name of the ev.h header file used to include it. The default if undefined is "ev.h" in event.h, ev.c and ev++.h. This can be used to virtually rename the ev.h header file in case of conflicts.

EV_CONFIG_H (h)
If EV_STANDALONE isn't 1, this variable can be used to override ev.c's idea of where to find the config.h file, similarly to EV_H, above.

EV_EVENT_H (h)
Similarly to EV_H, this macro can be used to override event.c's idea of how the event.h header can be found, the default is "event.h".

EV_PROTOTYPES (h)
If defined to be 0, then ev.h will not define any function prototypes, but still define all the structs and other symbols. This is occasionally useful if you want to provide your own wrapper functions around libev functions.

EV_MULTIPLICITY
If undefined or defined to 1, then all event-loop-specific functions will have the struct ev_loop * as first argument, and you can create additional independent event loops. Otherwise there will be no support for multiple event loops and there is no first event loop pointer argument. Instead, all functions act on the single default loop.

Note that EV_DEFAULT and EV_DEFAULT_ will no longer provide a default loop when multiplicity is switched off - you always have to initialise the loop manually in this case.

EV_MINPRI
EV_MAXPRI
The range of allowed priorities. EV_MINPRI must be smaller or equal to EV_MAXPRI, but otherwise there are no non-obvious limitations. You can provide for more priorities by overriding those symbols (usually defined to be -2 and 2, respectively).

When doing priority-based operations, libev usually has to linearly search all the priorities, so having many of them (hundreds) uses a lot of space and time, so using the defaults of five priorities (-2 .. +2) is usually fine.

If your embedding application does not need any priorities, defining these both to 0 will save some memory and CPU.

EV_PERIODIC_ENABLE, EV_IDLE_ENABLE, EV_EMBED_ENABLE, EV_STAT_ENABLE, EV_PREPARE_ENABLE, EV_CHECK_ENABLE, EV_FORK_ENABLE, EV_SIGNAL_ENABLE, EV_ASYNC_ENABLE, EV_CHILD_ENABLE.
If undefined or defined to be 1 (and the platform supports it), then the respective watcher type is supported. If defined to be 0, then it is not. Disabling watcher types mainly saves code size.

EV_FEATURES
If you need to shave off some kilobytes of code at the expense of some speed (but with the full API), you can define this symbol to request certain subsets of functionality. The default is to enable all features that can be enabled on the platform.

A typical way to use this symbol is to define it to 0 (or to a bitset with some broad features you want) and then selectively re-enable additional parts you want, for example if you want everything minimal, but multiple event loop support, async and child watchers and the poll backend, use this:

#define EV_FEATURES 0
#define EV_MULTIPLICITY 1
#define EV_USE_POLL 1
#define EV_CHILD_ENABLE 1
#define EV_ASYNC_ENABLE 1

The actual value is a bitset, it can be a combination of the following values (by default, all of these are enabled):

1 - faster/larger code
Use larger code to speed up some operations.

Currently this is used to override some inlining decisions (enlarging the code size by roughly 30% on amd64).

When optimising for size, use of compiler flags such as -Os with gcc is recommended, as well as -DNDEBUG, as libev contains a number of assertions.

The default is off when __OPTIMIZE_SIZE__ is defined by your compiler (e.g. gcc with -Os).

2 - faster/larger data structures
Replaces the small 2-heap for timer management by a faster 4-heap, larger hash table sizes and so on. This will usually further increase code size and can additionally have an effect on the size of data structures at runtime.

The default is off when __OPTIMIZE_SIZE__ is defined by your compiler (e.g. gcc with -Os).

4 - full API configuration
This enables priorities (sets EV_MAXPRI=2 and EV_MINPRI=-2), and enables multiplicity (EV_MULTIPLICITY=1).

8 - full API
This enables a lot of the "lesser used" API functions. See ev.h for details on which parts of the API are still available without this feature, and do not complain if this subset changes over time.

16 - enable all optional watcher types
Enables all optional watcher types. If you want to selectively enable only some watcher types other than I/O and timers (e.g. prepare, embed, async, child...) you can enable them manually by defining EV_watchertype_ENABLE to 1 instead.

32 - enable all backends
This enables all backends - without this feature, you need to enable at least one backend manually (EV_USE_SELECT is a good choice).

64 - enable OS-specific "helper" APIs
Enable inotify, eventfd, signalfd and similar OS-specific helper APIs by default.

Compiling with gcc -Os -DEV_STANDALONE -DEV_USE_EPOLL=1 -DEV_FEATURES=0 reduces the compiled size of libev from 24.7Kb code/2.8Kb data to 6.5Kb code/0.3Kb data on my GNU/Linux amd64 system, while still giving you I/O watchers, timers and monotonic clock support.

With an intelligent-enough linker (gcc+binutils are intelligent enough when you use -Wl,--gc-sections -ffunction-sections) functions unused by your program might be left out as well - a binary starting a timer and an I/O watcher then might come out at only 5Kb.

EV_API_STATIC
If this symbol is defined (by default it is not), then all identifiers will have static linkage. This means that libev will not export any identifiers, and you cannot link against libev anymore. This can be useful when you embed libev, only want to use libev functions in a single file, and do not want its identifiers to be visible.

To use this, define EV_API_STATIC and include ev.c in the file that wants to use libev.

This option only works when libev is compiled with a C compiler, as C++ doesn't support the required declaration syntax.

EV_AVOID_STDIO
If this is set to 1 at compiletime, then libev will avoid using stdio functions (printf, scanf, perror etc.). This will increase the code size somewhat, but if your program doesn't otherwise depend on stdio and your libc allows it, this avoids linking in the stdio library which is quite big.

Note that error messages might become less precise when this option is enabled.

EV_NSIG
The highest supported signal number, +1 (or, the number of signals): Normally, libev tries to deduce the maximum number of signals automatically, but sometimes this fails, in which case it can be specified. Also, using a lower number than detected (32 should be good for about any system in existence) can save some memory, as libev statically allocates some 12-24 bytes per signal number.

EV_PID_HASHSIZE
ev_child watchers use a small hash table to distribute workload by pid. The default size is 16 (or 1 with EV_FEATURES disabled), usually more than enough. If you need to manage thousands of children you might want to increase this value (must be a power of two).

EV_INOTIFY_HASHSIZE
ev_stat watchers use a small hash table to distribute workload by inotify watch id. The default size is 16 (or 1 with EV_FEATURES disabled), usually more than enough. If you need to manage thousands of ev_stat watchers you might want to increase this value (must be a power of two).

EV_USE_4HEAP
Heaps are not very cache-efficient. To improve the cache-efficiency of the timer and periodics heaps, libev uses a 4-heap when this symbol is defined to 1. The 4-heap uses more complicated (longer) code but has noticeably faster performance with many (thousands) of watchers.

The default is 1, unless EV_FEATURES overrides it, in which case it will be 0.

EV_HEAP_CACHE_AT
Heaps are not very cache-efficient. To improve the cache-efficiency of the timer and periodics heaps, libev can cache the timestamp (at) within the heap structure (selected by defining EV_HEAP_CACHE_AT to 1), which uses 8-12 bytes more per watcher and a few hundred bytes more code, but avoids random read accesses on heap changes. This improves performance noticeably with many (hundreds) of watchers.

The default is 1, unless EV_FEATURES overrides it, in which case it will be 0.

EV_VERIFY
Controls how much internal verification (see ev_verify ()) will be done: If set to 0, no internal verification code will be compiled in. If set to 1, then verification code will be compiled in, but not called. If set to 2, then the internal verification code will be called once per loop, which can slow down libev. If set to 3, then the verification code will be called very frequently, which will slow down libev considerably.

The default is 1, unless EV_FEATURES overrides it, in which case it will be 0.

EV_COMMON
By default, all watchers have a void *data member. By redefining this macro to something else you can include more and other types of members. You have to define it each time you include one of the files, though, and it must be identical each time.

For example, the perl EV module uses something like this:

#define EV_COMMON                       \
SV *self; /* contains this struct */  \
SV *cb_sv, *fh /* note no trailing ";" */

EV_CB_DECLARE (type)
EV_CB_INVOKE (watcher, revents)
ev_set_cb (ev, cb)
Can be used to change the callback member declaration in each watcher, and the way callbacks are invoked and set. Must expand to a struct member definition and a statement, respectively. See the ev.h header file for their default definitions. One possible use for overriding these is to avoid the struct ev_loop * as first argument in all cases, or to use method calls instead of plain function calls in C++.

EXPORTED API SYMBOLS

If you need to re-export the API (e.g. via a DLL) and you need a list of exported symbols, you can use the provided Symbol.* files which list all public symbols, one per line:

Symbols.ev      for libev proper
Symbols.event   for the libevent emulation

This can also be used to rename all public symbols to avoid clashes with multiple versions of libev linked together (which is obviously bad in itself, but sometimes it is inconvenient to avoid this).

A sed command like this will create wrapper #define's that you need to include before including ev.h:

<Symbols.ev sed -e "s/.*/#define & myprefix_&/" >wrap.h

This would create a file wrap.h which essentially looks like this:

#define ev_backend     myprefix_ev_backend
#define ev_check_start myprefix_ev_check_start
#define ev_check_stop  myprefix_ev_check_stop
...

EXAMPLES

For a real-world example of a program the includes libev verbatim, you can have a look at the EV perl module (http://software.schmorp.de/pkg/EV.html). It has the libev files in the libev/ subdirectory and includes them in the EV/EVAPI.h (public interface) and EV.xs (implementation) files. Only the EV.xs file will be compiled. It is pretty complex because it provides its own header file.

The usage in rxvt-unicode is simpler. It has a ev_cpp.h header file that everybody includes and which overrides some configure choices:

#define EV_FEATURES 8
#define EV_USE_SELECT 1
#define EV_PREPARE_ENABLE 1
#define EV_IDLE_ENABLE 1
#define EV_SIGNAL_ENABLE 1
#define EV_CHILD_ENABLE 1
#define EV_USE_STDEXCEPT 0
#define EV_CONFIG_H <config.h>

#include "ev++.h"

And a ev_cpp.C implementation file that contains libev proper and is compiled:

#include "ev_cpp.h"
#include "ev.c"

INTERACTION WITH OTHER PROGRAMS, LIBRARIES OR THE ENVIRONMENT

THREADS AND COROUTINES

THREADS

All libev functions are reentrant and thread-safe unless explicitly documented otherwise, but libev implements no locking itself. This means that you can use as many loops as you want in parallel, as long as there are no concurrent calls into any libev function with the same loop parameter (ev_default_* calls have an implicit default loop parameter, of course): libev guarantees that different event loops share no data structures that need any locking.

Or to put it differently: calls with different loop parameters can be done concurrently from multiple threads, calls with the same loop parameter must be done serially (but can be done from different threads, as long as only one thread ever is inside a call at any point in time, e.g. by using a mutex per loop).

Specifically to support threads (and signal handlers), libev implements so-called ev_async watchers, which allow some limited form of concurrency on the same event loop, namely waking it up "from the outside".

If you want to know which design (one loop, locking, or multiple loops without or something else still) is best for your problem, then I cannot help you, but here is some generic advice:

* most applications have a main thread: use the default libev loop in that thread, or create a separate thread running only the default loop.
    This helps integrating other libraries or software modules that use libev themselves and don't care/know about threading.

* one loop per thread is usually a good model.
    Doing this is almost never wrong, sometimes a better-performance model exists, but it is always a good start.

* other models exist, such as the leader/follower pattern, where one loop is handed through multiple threads in a kind of round-robin fashion.
    Choosing a model is hard - look around, learn, know that usually you can do better than you currently do :-)

* often you need to talk to some other thread which blocks in the event loop.
    ev_async watchers can be used to wake them up from other threads safely (or from signal contexts...).

    An example use would be to communicate signals or other events that only work in the default loop by registering the signal watcher with the default loop and triggering an ev_async watcher from the default loop watcher callback into the event loop interested in the signal.

    See also THREAD LOCKING EXAMPLE.

    COROUTINES

    Libev is very accommodating to coroutines ("cooperative threads"): libev fully supports nesting calls to its functions from different coroutines (e.g. you can call ev_run on the same loop from two different coroutines, and switch freely between both coroutines running the loop, as long as you don't confuse yourself). The only exception is that you must not do this from ev_periodic reschedule callbacks.

    Care has been taken to ensure that libev does not keep local state inside ev_run, and other calls do not usually allow for coroutine switches as they do not call any callbacks.

    COMPILER WARNINGS

    Depending on your compiler and compiler settings, you might get no or a lot of warnings when compiling libev code. Some people are apparently scared by this.

    However, these are unavoidable for many reasons. For one, each compiler has different warnings, and each user has different tastes regarding warning options. "Warn-free" code therefore cannot be a goal except when targeting a specific compiler and compiler-version.

    Another reason is that some compiler warnings require elaborate workarounds, or other changes to the code that make it less clear and less maintainable.

    And of course, some compiler warnings are just plain stupid, or simply wrong (because they don't actually warn about the condition their message seems to warn about). For example, certain older gcc versions had some warnings that resulted in an extreme number of false positives. These have been fixed, but some people still insist on making code warn-free with such buggy versions.

    While libev is written to generate as few warnings as possible, "warn-free" code is not a goal, and it is recommended not to build libev with any compiler warnings enabled unless you are prepared to cope with them (e.g. by ignoring them). Remember that warnings are just that: warnings, not errors, or proof of bugs.

    VALGRIND

    Valgrind has a special section here because it is a popular tool that is highly useful. Unfortunately, valgrind reports are very hard to interpret.

    If you think you found a bug (memory leak, uninitialised data access etc.) in libev, then check twice: If valgrind reports something like:

    ==2274==    definitely lost: 0 bytes in 0 blocks.
    ==2274==      possibly lost: 0 bytes in 0 blocks.
    ==2274==    still reachable: 256 bytes in 1 blocks.

    Then there is no memory leak, just as memory accounted to global variables is not a memleak - the memory is still being referenced, and didn't leak.

    Similarly, under some circumstances, valgrind might report kernel bugs as if it were a bug in libev (e.g. in realloc or in the poll backend, although an acceptable workaround has been found here), or it might be confused.

    Keep in mind that valgrind is a very good tool, but only a tool. Don't make it into some kind of religion.

    If you are unsure about something, feel free to contact the mailing list with the full valgrind report and an explanation on why you think this is a bug in libev (best check the archives, too :). However, don't be annoyed when you get a brisk "this is no bug" answer and take the chance of learning how to interpret valgrind properly.

    If you need, for some reason, empty reports from valgrind for your project I suggest using suppression lists.

    PORTABILITY NOTES

    GNU/LINUX 32 BIT LIMITATIONS

    GNU/Linux is the only common platform that supports 64 bit file/large file interfaces but disables them by default.

    That means that libev compiled in the default environment doesn't support files larger than 2GiB or so, which mainly affects ev_stat watchers.

    Unfortunately, many programs try to work around this GNU/Linux issue by enabling the large file API, which makes them incompatible with the standard libev compiled for their system.

    Likewise, libev cannot enable the large file API itself as this would suddenly make it incompatible to the default compile time environment, i.e. all programs not using special compile switches.

    OS/X AND DARWIN BUGS

    The whole thing is a bug if you ask me - basically any system interface you touch is broken, whether it is locales, poll, kqueue or even the OpenGL drivers.

    kqueue is buggy

    The kqueue syscall is broken in all known versions - most versions support only sockets, many support pipes.

    Libev tries to work around this by not using kqueue by default on this rotten platform, but of course you can still ask for it when creating a loop - embedding a socket-only kqueue loop into a select-based one is probably going to work well.

    poll is buggy

    Instead of fixing kqueue, Apple replaced their (working) poll implementation by something calling kqueue internally around the 10.5.6 release, so now kqueue and poll are broken.

    Libev tries to work around this by not using poll by default on this rotten platform, but of course you can still ask for it when creating a loop.

    select is buggy

    All that's left is select, and of course Apple found a way to fuck this one up as well: On OS/X, select actively limits the number of file descriptors you can pass in to 1024 - your program suddenly crashes when you use more.

    There is an undocumented "workaround" for this - defining _DARWIN_UNLIMITED_SELECT, which libev tries to use, so select should work on OS/X.

    SOLARIS PROBLEMS AND WORKAROUNDS

    errno reentrancy

    The default compile environment on Solaris is unfortunately so thread-unsafe that you can't even use components/libraries compiled without -D_REENTRANT in a threaded program, which, of course, isn't defined by default. A valid, if stupid, implementation choice.

    If you want to use libev in threaded environments you have to make sure it's compiled with _REENTRANT defined.

    Event port backend

    The scalable event interface for Solaris is called "event ports". Unfortunately, this mechanism is very buggy in all major releases. If you run into high CPU usage, your program freezes or you get a large number of spurious wakeups, make sure you have all the relevant and latest kernel patches applied. No, I don't know which ones, but there are multiple ones to apply, and afterwards, event ports actually work great.

    If you can't get it to work, you can try running the program by setting the environment variable LIBEV_FLAGS=3 to only allow poll and select backends.

    AIX POLL BUG

    AIX unfortunately has a broken poll.h header. Libev works around this by trying to avoid the poll backend altogether (i.e. it's not even compiled in), which normally isn't a big problem as select works fine with large bitsets on AIX, and AIX is dead anyway.

    WIN32 PLATFORM LIMITATIONS AND WORKAROUNDS

    General issues

    Win32 doesn't support any of the standards (e.g. POSIX) that libev requires, and its I/O model is fundamentally incompatible with the POSIX model. Libev still offers limited functionality on this platform in the form of the EVBACKEND_SELECT backend, and only supports socket descriptors. This only applies when using Win32 natively, not when using e.g. cygwin. Actually, it only applies to the microsofts own compilers, as every compiler comes with a slightly differently broken/incompatible environment.

    Lifting these limitations would basically require the full re-implementation of the I/O system. If you are into this kind of thing, then note that glib does exactly that for you in a very portable way (note also that glib is the slowest event library known to man).

    There is no supported compilation method available on windows except embedding it into other applications.

    Sensible signal handling is officially unsupported by Microsoft - libev tries its best, but under most conditions, signals will simply not work.

    Not a libev limitation but worth mentioning: windows apparently doesn't accept large writes: instead of resulting in a partial write, windows will either accept everything or return ENOBUFS if the buffer is too large, so make sure you only write small amounts into your sockets (less than a megabyte seems safe, but this apparently depends on the amount of memory available).

    Due to the many, low, and arbitrary limits on the win32 platform and the abysmal performance of winsockets, using a large number of sockets is not recommended (and not reasonable). If your program needs to use more than a hundred or so sockets, then likely it needs to use a totally different implementation for windows, as libev offers the POSIX readiness notification model, which cannot be implemented efficiently on windows (due to Microsoft monopoly games).

    A typical way to use libev under windows is to embed it (see the embedding section for details) and use the following evwrap.h header file instead of ev.h:

#define EV_STANDALONE              /* keeps ev from requiring config.h */
#define EV_SELECT_IS_WINSOCKET 1   /* configure libev for windows select */

#include "ev.h"

And compile the following evwrap.c file into your project (make sure you do not compile the ev.c or any other embedded source files!):

#include "evwrap.h"
#include "ev.c"

The winsocket select function

The winsocket select function doesn't follow POSIX in that it requires socket handles and not socket file descriptors (it is also extremely buggy). This makes select very inefficient, and also requires a mapping from file descriptors to socket handles (the Microsoft C runtime provides the function _open_osfhandle for this). See the discussion of the EV_SELECT_USE_FD_SET, EV_SELECT_IS_WINSOCKET and EV_FD_TO_WIN32_HANDLE preprocessor symbols for more info.

The configuration for a "naked" win32 using the Microsoft runtime libraries and raw winsocket select is:

#define EV_USE_SELECT 1
#define EV_SELECT_IS_WINSOCKET 1   /* forces EV_SELECT_USE_FD_SET, too */

Note that winsockets handling of fd sets is O(n), so you can easily get a complexity in the O(n²) range when using win32.

Limited number of file descriptors

Windows has numerous arbitrary (and low) limits on things.

Early versions of winsocket's select only supported waiting for a maximum of 64 handles (probably owning to the fact that all windows kernels can only wait for 64 things at the same time internally; Microsoft recommends spawning a chain of threads and wait for 63 handles and the previous thread in each. Sounds great!).

Newer versions support more handles, but you need to define FD_SETSIZE to some high number (e.g. 2048) before compiling the winsocket select call (which might be in libev or elsewhere, for example, perl and many other interpreters do their own select emulation on windows).

Another limit is the number of file descriptors in the Microsoft runtime libraries, which by default is 64 (there must be a hidden 64 fetish or something like this inside Microsoft). You can increase this by calling _setmaxstdio, which can increase this limit to 2048 (another arbitrary limit), but is broken in many versions of the Microsoft runtime libraries. This might get you to about 512 or 2048 sockets (depending on windows version and/or the phase of the moon). To get more, you need to wrap all I/O functions and provide your own fd management, but the cost of calling select (O(n²)) will likely make this unworkable.

PORTABILITY REQUIREMENTS

In addition to a working ISO-C implementation and of course the backend-specific APIs, libev relies on a few additional extensions:

void (*)(ev_watcher_type *, int revents) must have compatible calling conventions regardless of ev_watcher_type *.
Libev assumes not only that all watcher pointers have the same internal structure (guaranteed by POSIX but not by ISO C for example), but it also assumes that the same (machine) code can be used to call any watcher callback: The watcher callbacks have different type signatures, but libev calls them using an ev_watcher * internally.

pointer accesses must be thread-atomic
Accessing a pointer value must be atomic, it must both be readable and writable in one piece - this is the case on all current architectures.

sig_atomic_t volatile must be thread-atomic as well
The type sig_atomic_t volatile (or whatever is defined as EV_ATOMIC_T) must be atomic with respect to accesses from different threads. This is not part of the specification for sig_atomic_t, but is believed to be sufficiently portable.

sigprocmask must work in a threaded environment
Libev uses sigprocmask to temporarily block signals. This is not allowed in a threaded program (pthread_sigmask has to be used). Typical pthread implementations will either allow sigprocmask in the "main thread" or will block signals process-wide, both behaviours would be compatible with libev. Interaction between sigprocmask and pthread_sigmask could complicate things, however.

The most portable way to handle signals is to block signals in all threads except the initial one, and run the signal handling loop in the initial thread as well.

long must be large enough for common memory allocation sizes
To improve portability and simplify its API, libev uses long internally instead of size_t when allocating its data structures. On non-POSIX systems (Microsoft...) this might be unexpectedly low, but is still at least 31 bits everywhere, which is enough for hundreds of millions of watchers.

double must hold a time value in seconds with enough accuracy
The type double is used to represent timestamps. It is required to have at least 51 bits of mantissa (and 9 bits of exponent), which is good enough for at least into the year 4000 with millisecond accuracy (the design goal for libev). This requirement is overfulfilled by implementations using IEEE 754, which is basically all existing ones.

With IEEE 754 doubles, you get microsecond accuracy until at least the year 2255 (and millisecond accuracy till the year 287396 - by then, libev is either obsolete or somebody patched it to use long double or something like that, just kidding).

If you know of other additional requirements drop me a note.

ALGORITHMIC COMPLEXITIES

In this section the complexities of (many of) the algorithms used inside libev will be documented. For complexity discussions about backends see the documentation for ev_default_init.

All of the following are about amortised time: If an array needs to be extended, libev needs to realloc and move the whole array, but this happens asymptotically rarer with higher number of elements, so O(1) might mean that libev does a lengthy realloc operation in rare cases, but on average it is much faster and asymptotically approaches constant time.

Starting and stopping timer/periodic watchers: O(log skipped_other_timers)
This means that, when you have a watcher that triggers in one hour and there are 100 watchers that would trigger before that, then inserting will have to skip roughly seven (ld 100) of these watchers.

Changing timer/periodic watchers (by autorepeat or calling again): O(log skipped_other_timers)
That means that changing a timer costs less than removing/adding them, as only the relative motion in the event queue has to be paid for.

Starting io/check/prepare/idle/signal/child/fork/async watchers: O(1)
These just add the watcher into an array or at the head of a list.

Stopping check/prepare/idle/fork/async watchers: O(1)
Stopping an io/signal/child watcher: O(number_of_watchers_for_this_(fd/signal/pid % EV_PID_HASHSIZE))
These watchers are stored in lists, so they need to be walked to find the correct watcher to remove. The lists are usually short (you don't usually have many watchers waiting for the same fd or signal: one is typical, two is rare).

Finding the next timer in each loop iteration: O(1)
By virtue of using a binary or 4-heap, the next timer is always found at a fixed position in the storage array.

Each change on a file descriptor per loop iteration: O(number_of_watchers_for_this_fd)
A change means an I/O watcher gets started or stopped, which requires libev to recalculate its status (and possibly tell the kernel, depending on backend and whether ev_io_set was used).

Activating one watcher (putting it into the pending state): O(1)
Priority handling: O(number_of_priorities)
Priorities are implemented by allocating some space for each priority. When doing priority-based operations, libev usually has to linearly search all the priorities, but starting/stopping and activating watchers becomes O(1) with respect to priority handling.

Sending an ev_async: O(1)
Processing ev_async_send: O(number_of_async_watchers)
Processing signals: O(max_signal_number)
Sending involves a system call iff there were no other ev_async_send calls in the current loop iteration and the loop is currently blocked. Checking for async and signal events involves iterating over all running async watchers or all signal numbers.

PORTING FROM LIBEV 3.X TO 4.X

The major version 4 introduced some incompatible changes to the API.

At the moment, the ev.h header file provides compatibility definitions for all changes, so most programs should still compile. The compatibility layer might be removed in later versions of libev, so better update to the new API early than late.

EV_COMPAT3 backwards compatibility mechanism
The backward compatibility mechanism can be controlled by EV_COMPAT3. See "PREPROCESSOR SYMBOLS/MACROS" in the EMBEDDING section.

ev_default_destroy and ev_default_fork have been removed
These calls can be replaced easily by their ev_loop_xxx counterparts:

ev_loop_destroy (EV_DEFAULT_UC);
ev_loop_fork (EV_DEFAULT);

function/symbol renames
A number of functions and symbols have been renamed:

ev_loop         => ev_run
EVLOOP_NONBLOCK => EVRUN_NOWAIT
EVLOOP_ONESHOT  => EVRUN_ONCE

ev_unloop       => ev_break
EVUNLOOP_CANCEL => EVBREAK_CANCEL
EVUNLOOP_ONE    => EVBREAK_ONE
EVUNLOOP_ALL    => EVBREAK_ALL

EV_TIMEOUT      => EV_TIMER

ev_loop_count   => ev_iteration
ev_loop_depth   => ev_depth
ev_loop_verify  => ev_verify

Most functions working on struct ev_loop objects don't have an ev_loop_ prefix, so it was removed; ev_loop, ev_unloop and associated constants have been renamed to not collide with the struct ev_loop anymore and EV_TIMER now follows the same naming scheme as all other watcher types. Note that ev_loop_fork is still called ev_loop_fork because it would otherwise clash with the ev_fork typedef.

EV_MINIMAL mechanism replaced by EV_FEATURES
The preprocessor symbol EV_MINIMAL has been replaced by a different mechanism, EV_FEATURES. Programs using EV_MINIMAL usually compile and work, but the library code will of course be larger.

GLOSSARY

active
A watcher is active as long as it has been started and not yet stopped. See WATCHER STATES for details.

application
In this document, an application is whatever is using libev.

backend
The part of the code dealing with the operating system interfaces.

callback
The address of a function that is called when some event has been detected. Callbacks are being passed the event loop, the watcher that received the event, and the actual event bitset.

callback/watcher invocation
The act of calling the callback associated with a watcher.

event
A change of state of some external event, such as data now being available for reading on a file descriptor, time having passed or simply not having any other events happening anymore.

In libev, events are represented as single bits (such as EV_READ or EV_TIMER).

event library
A software package implementing an event model and loop.

event loop
An entity that handles and processes external events and converts them into callback invocations.

event model
The model used to describe how an event loop handles and processes watchers and events.

pending
A watcher is pending as soon as the corresponding event has been detected. See WATCHER STATES for details.

real time
The physical time that is observed. It is apparently strictly monotonic :)

wall-clock time
The time and date as shown on clocks. Unlike real time, it can actually be wrong and jump forwards and backwards, e.g. when you adjust your clock.

watcher
A data structure that describes interest in certain events. Watchers need to be started (attached to an event loop) before they can receive events.

AUTHOR

Marc Lehmann <libev@schmorp.de>, with repeated corrections by Mikael Magnusson and Emanuele Giaquinta, and minor corrections by many others.





