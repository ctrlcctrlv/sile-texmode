# LaTeX mode for SILE

![](https://raw.githubusercontent.com/ctrlcctrlv/sile-texmode/master/examples/evil%3F.png)

What it says on the tin. You type:

```
P\|{e}h-\={o}e-j\={i}---a method of writing Taiwanese
```

You get:

> Pe̍h-ōe-jī—a method of writing Taiwanese

Please see the [examples](https://github.com/ctrlcctrlv/sile-texmode/tree/master/examples).

## Dependencies
* SILE >= v0.10.5.r107-g36868e2, *not* compatible with v0.10.5 or lower (so, all current releases as of 2020-07-15, only works on developer builds), as we need PR&numero;[940](https://github.com/sile-typesetter/sile/pull/940).
* (To build `evil?.sil`) [sile-strike](https://github.com/ctrlcctrlv/sile-strike)

## Features
1. All common TeX ligatures (go to function texmode and grep for `:gsub` for a list; feel free to open issues/PRs if any you like are missing)
1. TeX diacritic helpers (We support all on the list in Scott Pakin's [Comprehensive LaTeX Symbol List](https://mirrors.concertpass.com/tex-archive/info/symbols/comprehensive/symbols-a4.pdf), 25 June 2020 edition.)
1. A comprehensive list of math symbols [via Cumhur Korkut](http://github.com/joom/latex-unicoder.vim) (see file `packages/texmode/unicoder.lua`), and the most important text ones (`grep` the aforementioned file for `Fred's`). (As &numero;1, feel free to open issues for more, preferably hundreds of symbols in Lua table format all ready to go please! 😉)
1. A `\notex` command, which ignores what's inside it!
1. `nosymbols=y` or `nocombine=y` to disable what TeX stuff you don't like. (Come on, what did TeX ever do to you! Embrace the suck!)

## Usage

Just as jQuery conditioned JavaScript developers of a certain generation to write a Hello, World! as...

```
$(document).ready(function(){
    alert("おっす、世界！元気のか！俺、ハイ！さって〜じゃね‼‼");
});
```

So too do I aim to condition you.

Here's our Hello, World!

```
\begin{document}\script[src=packages/texmode]\texmode[_="% ]
Hello, world!
"]\end{document}
```

It is recommended to put it all on one line so error lineno's continue to function. The comment, `% ]`, fixes vim. At least, until @alerque fixes his script, then it might not be necessary anymore. But we probably won't want his fixed script, since it'll probably interpret documents like ours as containing a long string, since that's what they are in the grammar. So remember this number: [`09cecddad7`](https://github.com/sile-typesetter/vim-sile/commit/09cecddad7f84d7659aa94481344d13ba2a54bb5), it's the revision of `vim-sile` this works on.

Everything should go inside the bottom and top line. If necessary, you can though call `\texmode` more than once.

## Known issues
Due to the way PR&numero;940 was fixed, (I didn't get to comment until it was merged, I was hoping they'd add Python-esque `"""` super-quotes, or even better, Rust style raw string literals in the form of `r#"sup"#`, where, if for some absurd reason you need to write `"#`, you just make it `r##"sup"#"##`. _Ad infinitum, et ultra!!_) the TeX `"` can't be used as is. You need to escape it.

```
\begin{document}\script[src=packages/texmode]\texmode[_="% ]
\script[src=packages/font-fallback]
\font:add-fallback[font=Noto Sans CJK JP]
% This is exactly how Japanese people talk. Anime and nichanneru, extremely reliable sources, taught me that.
おっす、世界！元気のか！俺ハイハイ！さって〜行くぞ！じゃね‼‼

The above is known as a ``quote". % won't work!
The above is known as a ``quote\". % will work!
"]\end{document}
```

![](https://raw.githubusercontent.com/ctrlcctrlv/sile-texmode/master/examples/dblquote.png)

Anyway, you know that even in TeX ``` ``this" ``` is bad, right? It's unbalanced in monospace, silly! Do it ``` ``this way'' ```.

## License

```
Copyright 2020, Fredrick R. Brennan (@ctrlcctrlv)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
```
