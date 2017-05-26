---
layout: post
title: "jekyll图片管理插件"
---

使用jekyll搭建github的pages服务已经很多年了，虽然写的blog不是特别多，但在使用的过程中难免还是遇到了很多的问题。在所有这些问题中，几乎所有的问题都被解决了。但有且只有一个问题几乎无解：图片管理。使用jekyll的程序员几乎都搭配markdown，但是markdown对于图片的管理，简直就是可以用一坨屎来形容。  

### 以前问题 
  
* * * 

通常在markdown中，引用图片都是使用标记来进行。但是引用的图片路径往往是一个问题。优先了jekyll，那么本地的编辑器可能就无法显示和预览；优先了本地预览，那么markdown上传到jekyll后路径是一个问题。   

那么我们最常用的就是这种办法：因为markdown引用图片最常用的就是http形式的地址引用。所以前提就是你必须先有一个稳定的图床，然后上传图片，获取地址，再把地址贴入markdown中。这种方式我受不了的地方在于中间插入图片或者修改图片多次的话，往往需要长时间的停下来先弄图片，再写markdown，整个思路会受到很多的影响。有时候弄完图片已经没心情再写东西了。  

那么有没有一种办法来解决这个问题呢？  

首先我们想到了一种办法，把图片直接放到某个文件夹里面，上传到github，但是这样的做法还是会在本地编辑器和jekyll中满足一个。另外一个办法，就是把图片和markdown放在同一个文件夹，这样就没有路径问题了，直接用文件名就可以引用图片。但是这种办法满足了编辑器，在jekyll build的时候，jekyll对于_post目录下的文件只处理markdown文件，不会处理别的文件。看上去这条路也不通了。  

那么到底有没有别的办法呢？  

### 我的解决方案  

* * * 

其实能想到的方案上面都已经全部想到了，但是不管怎么去解决，在jekyll和本地编辑器中往往只能满足一个，两个能同时兼顾的就没有。但是对比上面的几种方案，最靠谱的貌似还是最后一种** markdown和图片同目录 ** 但是在同目录jekyll又不管，幸好jekyll提供了插件功能。  

jekyll的插件有很多种，具体的请查看 [jekyll插件科普](http://jekyllcn.com/docs/plugins/) 

回到我们的问题，我们的问题其实已经很清楚了，就是在jekyll解析markdown到html的同时，将同目录的静态文件全部cp到生成的html的目录。这样markdown文件生成的html和静态资源文件又在一个目录下了，这样就可以避免目录的问题了。  

在这些插件的hooks中，我们选择了 :posts :post_write 这个hooks，因为这个hooks是在markdown已经被解析，并且被写入磁盘以后发生的。这个时间点正好就是我们想要的这个时间点。那么我们现在就是只要实现这个hooks就可以了。所以就有了下面的代码：
  
    Jekyll::Hooks.register :posts, :post_write do |doc|
    # Minify HTML files after site build
    #  gulp = File.join(site.source, 'node_modules', '.bin', 'gulp')
    #  system "#{gulp} minifyHTML --silent"
    #
    #Kernel.puts "11111111111111111111"
    #Kernel.puts doc.path

    pn = Pathname.new(doc.path)
    basedir  = pn.dirname 
    dest_path =File.join(doc.site.config["destination"] , doc.url)
    Dir.foreach(basedir) {|x| 
        if !(x.start_with?("."))
            if !(x.end_with?("md") || x.end_with?("markdown"))
                stmp = File.join(basedir,x)
                dtmp = File.join(dest_path,x)
                Kernel.puts stmp
                Kernel.puts dtmp
                FileUtils.cp(stmp,dtmp)
                Kernel.puts "copy static file from #{stmp} to #{dtmp}"
            end
        end
    }

    end
    
将这个文件保存到_plugins目录下，随便给一个文件名即可。再次运行jekyll server就可以看到这个hooks被执行了。

具体的使用可以看我的blog源码 [blog源码](https://github.com/xvhfeng/blog-source)

### 缺点

* * *

这个解决方案并不是万能的，它也有自己的缺点。目前使用下来，缺点有几个：   
1. 只支持markdown和静态文件同目录的情况；   
2. 对于jekyll的permalink的配置一定要正确，千奇百怪的配置不一定可用，我的配置是/blog/:year/:title/，注意，最后那个目录分隔符 "/" 一定要带;  
3. 对于post中的markdown转html的时候，列表页的显示也有问题，如果列表页上会显示摘要或者是文章的一部分内容，而恰巧这部分在列表上显示的内容中有图片的引用，这样这个图片也会有显示问题。因为图片其实是在markdown生成的html目录，而列表页是一个单独的目录，所以图片路径是取不到的。这部分其实是可以完善的，但是对于我来说，这部分几乎很少用到，我也就没管了；  
4. 因为你使用了自定义的plugin，而github为了安全考虑是不支持自定义plugin的，所以对于使用自定义的用户来说，只能在本地build完了站点后，把_site目录下的文件签入github，使用静态文件的方式来提供blog的服务；（PS，好处时自定义的插件可以让你为所欲为，有失必有得）  
