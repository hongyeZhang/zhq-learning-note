# Git 学习笔记


## 基本操作命令

### 账号操作相关

```shell script
git config --global --list  # 显示全局



```




```shell script
更新远程分支列表  git remote update origin --prune  ==  git remote prune origin
git diff 显示尚未暂存的变化
git diff --cache  显示
git reset HEAD <file> 取消暂存操作
git checkout -- <fileName> 从暂存中撤销修改

```



### git pull
```shell script
git pull /projects/first-steps-clone master  

```


### git reset
重置暂存区
```
git reset HEAD foo.txt 将文件重置为当前HEAD版本





git reset --hard HEAD^        回退到上一版本
git reset --hard HEAD~100
git reset --hard [commitId]   回到未来的某个版本,其中commitId不需要写全
git reset HEAD [fileName]     把暂存区的修改回退到工作区。当我们用HEAD时，表示最新的版本
```


### git status 
```
git status
git status --short  查看状态


```


### git log

```
git log -n 3 最近的3次提交
git log --oneline 单行
git log --stat
git log --shortstat --oneline  --shortstat 则用来显示项目中有多少文件被修改，以及新增或删除了多少文件。
git log --graph --oneline



git rev-parse HEAD :                查询git log 的第一个 log 的 commit id
git rev-parse --short HEAD :        --short 可以获得较短的commit id
git rev-parse --abbrev-ref HEAD     提取出当前的 git 分支名称
git log                             查看提交历史，以便确定要回退到哪个版本
git reflog                          查看命令历史，以便确定要回到未来的哪个版本
git diff HEAD -- [readme.txt]         命令可以查看工作区和版本库里面最新版本的区别
git log --graph --pretty=oneline --abbrev-commit  用带参数的git log也可以看到分支的合并情况
git checkout -- [file]                可以丢弃工作区的修改
一种是readme.txt自修改后还没有被放到暂存区，现在，撤销修改就回到和版本库一模一样的状态；
一种是readme.txt已经添加到暂存区后，又作了修改，现在，撤销修改就回到添加到暂存区后的状态。
总之，就是让这个文件回到最近一次git commit或git add时的状态。

git log --oneline -10  查询最近10次的提交记录


```

### git diff

```
git diff <fileName>  显示文件被修改的行

```





### git rm
```
git rm test.txt                从git版本库中删除文件
git checkout -- [fileName]     将工作区删除的文件从版本库中进行恢复
```

### git branch 
```
查看分支：git branch
创建分支：git branch <name>
切换分支：git checkout <name>
创建+切换分支：git checkout -b <name>
合并某分支到当前分支：git merge <name>
删除分支：git branch -d <name>
强行删除分支：git branch -D <name>
设置本地分支与远程分支的联系   git branch --set-upstream-to=origin/dev dev
远程拉取并新建自己的分支  git checkout -b  myNewBranch  /origin/sprint.2.30.1.hq

```


### git stash 
```$xslt
git stash clear
git stash list               查看暂存区的内容
git stash apply stash@{0}    恢复指定的stash
git stash apply :应用某个存储,但不会把存储从存储列表中删除，默认使用第一个存储,即stash@{0}
git stash pop ：命令恢复之前缓存的工作目录，将缓存堆栈中的对应stash删除，并将对应修改应用到当前的工作目录下,默认为第一个stash,即stash@{0}，
                如果要应用并删除其他stash，命令：git stash pop stash@{$num} ，比如应用并删除第二个：git stash pop stash@{1}
git stash show 显示做了哪些改动，默认show第一个存储,如果要显示其他存贮，后面加stash@{$num}，比如第二个 git stash show stash@{1}
git stash show -p stash@{0}
git stash drop stash@{$num} ：丢弃stash@{$num}存储，从列表中删除这个存储
git stash clear ：删除所有缓存的stash
git stash save "save message"  : 执行存储时，添加备注，方便查找，只有git stash 也要可以的，但查找时不方便识别
git stash save -u "save message"  : 执行存储时，添加备注，方便查找，只有git stash 也要可以的，但查找时不方便识别

git stash save -u/-a
    -u： 会把没有记录到的文件也保存下来(比如你新建了一个文件，但是还没有git add，stash也会把这个文件保存下来)
    -a： 会把忽略的文件也保存下来（.gitignore中的）


```




### git merge
```$xslt
使用普通模式合并分支，默认使用快速模式   git merge --no-ff -m "merge with no-ff" dev
如果merge过程中冲突太多，放弃merge     git merge --abort

```

### git rebase
    rebase操作可以把本地未push的分叉提交历史整理成直线；
    rebase的目的是使得我们在查看历史提交的变化时更容易，因为分叉的提交需要三方对比。

### git tag
```$xslt
git tag <tagName> 标签默认打在最新提交的commit上，如果中途忘记打，则可以查看提交历史
git log --pretty=oneline --abbrev-commit  找到对应的Id
git log --oneline -10  单行的形式显示10条记录
git log --graph 日志的图形化版本

git tag <tagName> <commitId>
git tag -a <tagName> -m "description" <commitId>   创建带有说明的标签
推动标签到远程   git push origin <tagname>
一次性推送全部尚未推送到远程的本地标签：  git push origin --tags

如果标签已经推送到远程，要删除远程标签就麻烦一点，先从本地删除，再从远程删除
git tag -d v0.9
git push origin :refs/tags/v0.9

命令git push origin <tagname>可以推送一个本地标签；
命令git push origin --tags可以推送全部未推送过的本地标签；
命令git tag -d <tagname>可以删除一个本地标签；
命令git push origin :refs/tags/<tagname>可以删除一个远程标签。

```

### git 配置
    git config --global credential.helper store  不用每次输入账号密码

### git cherry-pick 

* git cherry-pick commitid  将某一个分支的 某一次提交合并到当前的分支上


        git cherry-pick 可以理解为”挑拣”提交，它会获取某一个分支的单笔提交，并作为一个新的提交引入到你当前分支上。 
        当我们需要在本地合入其他分支的提交时，如果我们不想对整个分支进行合并，而是只想将某一次提交合入到本地当前分支上，
        那么就要使用git cherry-pick了。
        用法
        git cherry-pick [<options>] <commit-ish>...
        常用options:
            --quit                退出当前的chery-pick序列
            --continue            继续当前的chery-pick序列
            --abort               取消当前的chery-pick序列，恢复当前分支
            -n, --no-commit       不自动提交
            -e, --edit            编辑提交信息



## 实操经验
    * 场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令git checkout -- file。
    * 场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令git reset HEAD <file>，
      就回到了场景1，第二步按场景1操作。
    * 场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，参考版本回退一节，不过前提是没有推送到远程库。

### 本地仓库与远程仓库关联
    远程建立一个仓库，根据github的提示操作即可
    git remote add origin https://github.com/hongyeZhang/ZHQRepo.git
    git push -u origin master  将文件推送到远程并建立联系
    要关联一个远程库，使用命令git remote add origin git@server-name:path/repo-name.git；
    关联后，使用命令git push -u origin master 第一次推送master分支的所有内容；
    此后，每次本地提交后，只要有必要，就可以使用命令git push origin master推送最新修改；

### 本地给远程仓库创建分支 
    git branch dev  (当前是哪个分支，就内容就默认与哪个分支相同)
    git push origin dev
    git push --set-upstream origin dev  (下次提交之后就可以直接 git push)
    建立本地分支和远程分支的关联，使用 git branch --set-upstream branch-name origin/branch-name

### 从mastr分支上解决bug 
    git checkout master
    git checkout -b bug-fix-001 创建并切换分支
    修改内容
    git add .
    git checkout master
    git merge --no-ff -m "bugfix-001"
    
### 多人合作 
    git remote -v    查看远程库的信息
    多人协作的工作模式通常是这样：
        首先，可以试图用 git push origin <branch-name>推送自己的修改；
        如果推送失败，则因为远程分支比你的本地更新，需要先用git pull试图合并；
        如果合并有冲突，则解决冲突，并在本地提交；
        没有冲突或者解决掉冲突后，再用git push origin <branch-name>推送就能成功！
        如果git pull提示no tracking information，则说明本地分支和远程分支的链接关系没有创建，
        用命令git branch --set-upstream-to <branch-name> origin/<branch-name>。
        
### 版本回退
    git revert <commitId>
    :q   直接退出提交的备注
    git push  将本地推送到远端
    合并其他分支上的某一次 commit  git cherry-pick [commitId]










