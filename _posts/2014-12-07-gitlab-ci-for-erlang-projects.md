---
layout: post
title: GitLab CI for Erlang Projects
description: "Example GitLab CI setup that can run tests for Erlang projects."
date: 2014-12-07 22:59:00 CET
category: posts
tags: [erlang, testing, programming, gitlabci, english]
comments: true
---

[GitLab CI](https://about.gitlab.com/gitlab-ci/) is GitLab's continuous integration software. It integrates with [GitLab](https://about.gitlab.com) and runs your tests every time a commit is pushed to the remote repository. Getting it to run tests for projects written in Erlang can be a bit of hassle, so in this post I will share and explain my setup.

This post assumes that the `gitlab_ci_runner` user is already able to switch between Erlang versions using [kerl](https://github.com/yrashk/kerl). The `kerl` README has some simple [usage instructions](https://github.com/yrashk/kerl#usage).

The CI runner (v5.0.0) is installed on an Ubuntu 14.04 machine and it talks to GitLab CI 5.2.1.

The build script that is used to run Erlang tests looks like this:

{% highlight bash %}
# Setup
source $HOME/.kerl/installs/17.3/activate
gitlabdir=$(basename `pwd`)
appdir=$(cat src/*.app.src | tr ',' '\n' | sed '2q;d' | tr -d ' ' | tr -d '\n')

# Rename directory
cd ..
rm -rf $appdir
mv $gitlabdir $appdir
cd $appdir

# Run tests
make dialyze
make tests

# Coverage
ls -rt $(find ./logs -name "cover.html") | tail -n 1 | xargs cat | grep -F 'Total' | awk '{gsub("<[^>]*>", "")}1'

# Cleanup
cd ..
mv $appdir $gitlabdir
cd $gitlabdir
{% endhighlight %}

**Setup**

This section activates an Erlang version and initializes two variables that hold directory names. `gitlabdir` is the name of current directory (e.g. `project-1`) and `appdir` is set to the name of the Erlang application that's being tested. If the application name "detection" does not work for you, you can just hard code it.

**Rename directory**

Since GitLab CI names directories in a way that does not work with many Erlang tools, we have to manually move the project directory. This is because the directory in which an Erlang application resides has to be named like the application itself.

The `rm` is there to clean up any directories that might exist because of failed test runs.

**Run tests**

My projects use [erlang.mk](https://github.com/ninenines/erlang.mk), which is why this part in the script might not work for your projects. You can easily fix this by replacing the two calls to `make` with whatever you use to run your tests.

**Coverage**

The test coverage is extracted from the latest `cover.html` file. It will be printed to *stdout* like this:

{% highlight text %}
Total97 %742
{% endhighlight %}

Since we're only interest in the `97`, we can set the "Test coverage parsing" option to this regular expression: `Total(\d+)\s\%`.

**Cleanup**

In the end, all we have to do is to undo our changes to the directory structure that GitLab CI expects.
