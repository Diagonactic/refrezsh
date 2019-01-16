# refrezsh
Making sure Google corrects your spelling every time you search for this project

## No, really, what is it

Joking aside, it's a personal project attempting to provide a sane default theme, well performing prompts (all 4), styled completion/menu completion with configuration defaults for use with terminals like `Alacritty`<sup>0</sup>

### You're taking a hard dependency on Alacritty? Isn't that Alpha?

No and Yes.  There isn't a hard dependency on Alacritty, though that's the terminal I use daily (yes, despite it being alpha, it works very well minus one or two little bugs).  The reason for `Alacritty` centers around Nerd Fonts, which as of version 2.x includes glyphs that occupy more than one character.  The prompt's default configuration makes use of these and adds spacing around them.  This results in abnormally large, readable, icons in the terminal while not corrupting the prompt.  I've not found a terminal outside of Alacritty that can handle this, but since Alacritty is nearly all I use, I haven't tested it either.

### Project Goals

#### Unopinionated, except on environment specifics

I like opinionated frameworks ... for my mom ... and sometimes for my phone.  I don't like them for my development environment.  I put this together because my existing prompt was missing a small number of features and lacked a couple of things in the way of configuration and adding those to the plug-in was going to be more work than writing a new one that did what I want.

My goal is to make every part of the prompt configurable, probably via `zstyle` (presently it's being done via associative variables set up in common.lib.zsh).

On the other hand, I am not interested in supporting text terminals or terminals that do not support "sometimes exotic" features like 24-bit ANSI, though I do plan to provide a configuration option to kill the Nerd Font 2.0 requirement.

#### Asynchronous ... maybe

Really, I'd like to just have this thing perform well enough that this isn't necessary.  If a feature has a lot of overhead and provides little benefit, I will avoid it but if a feature provides a great deal of benefit but cannot be performed in-process performantly, I'll opt to rewrite the prompt.  That's currently not implemented and I'm not certain of the approach I'll take.

The approach I'll avoid is one I've seen in several prompts that simulates asynchronous behavior, but in practice results in a prompt being printed that cannot be used until the updated prompt is printed.

#### Modular

This is partially implemented but will be refactored.  I want to support each section of the prompt as a group that can be turned on and off.  Presently they're on if it's discovered that the environment supports their operation (or, in the case of git, if the folder is a `git` repository).

#### Cross-platform performant

I'm specifically calling out "Cross-platform performance" because `zsh` performs radically differently on some platforms than others and one of these platforms is one I am forced to use with some frequency<sup>0</sup>

I still have one Windows box which I have to use from time to time and while new development has been done almost exclusively in Rider/openSUSE/.Net Core, I have a legacy application or two which requires me to hop over to that Windows box.

On Ubuntu on Windows, sub-shelling is crazy expensive.  Of course, outside of `zsh` there's a lot of things you simply cannot do without a subshell.  Since this is a `zsh` theme, I have gone through a lot of effort to eliminate `$()` and unnecessary pipes, or batched those calls into a single call (ala `lib/git.lib.zsh`).  This results in some fugly code and even fuglier expansions, but the difference is "usable" vs "unusable" (and I've found the latter to be the case on all but the simplest prompts on Ubuntu on Windows).

I'm assuming Microsoft will get around to smoothing that performance hitch out, but even assuming that, the script performs better in Linux without the unnecessary shelling.

<sup>0</sup> That sounds *_way_* more negative than it is intended -- I love Microsoft products, including Windows, I just prefer to develop on Linux and since that's my day job, I prefer to stick with Linux for everything when I can.

### Project State

Very, very alpha.  I strongly recommend that *nobody* use this in production in its state.  I'm using it as my default every day and will update when I'm confident the bugs are done.  As a result, I'm not providing install instructions, yet.  If you wish to try it out, feel free to clone and investigate.  For the most part, running the `.plugin.zsh` file with the parameter `load` is all that's needed.

### Requirements

 - A terminal capable of displaying all of the Nerd Font 2.0 glyphs - Alacritty works perfectly for this
   - Specifically, it must print a two-character glyph as occupying two characters, while only moving the caret forward one character
   - A Nerd Font 2.0 font must be the default font for the terminal (I use a modified Input font from fontbureau)
   - This requirement will be temporary - I plan to add support for falling back to Nerd Font 1.x and non-Nerd Fonts
 - A terminal capable of understanding 24-bit ANSI codes
   - Yes, I embedded the codes right in the prompt.
   - I intend to use terminfo to determine compatibility and to form the first 24-bit ANSI template, but will likely continue to embed ANSI codes since calling out using the zsh builtins or the terminfo tooling is far more expensive
   - Terminals that only understand 24-bit ANSI but fall back to 16-color or 256-color ANSI will work but will look rather different

### Possible Requirements

This covers things that are common about my environments that might not be for yours.  These may not be requirements, but I have not tested outside of these

 - Linux (specifically, I'm running OpenSUSE Tumbleweed) - I expect this would work in Windows/MacOS, too
 - A recent version of Zsh
   - At this point, I've only tested in `zsh 5.6.2` and `zsh 5.5.1`.  I expect some of the code will fall over in `5.x` -- I've had issues with array assignment parsing and other problems in older versions with other scripts so I'm just assuming it'll happen here.  Maybe it won't.  I haven't tested it.

### Feedback / Issues / Bugs

This is a personal project.  I don't expect anyone else to actually *use* it except for me.  The code quality reflects that in places.  I can nearly promise I won't have time to investigate issues, especially if I cannot easily replicate them.  Until the project leaves alpha, issues will be slow to be resolved.  

If you want to increase your chances of having your issue addressed (no promises):
 - The output of `lsb_release -a` (or equivalent if on Win/Mac).
 - The output of `zsh --version`
 - Anything unusual about your hardware/OS (I tested on Intel/AMD based x86 laptops/desktpos and servers, so I'm thinking things like RPis, Android Ubuntu, Ubuntu on Windows)
 - Please don't be a jerk - I am "a guy" not "a company".  I wrote this during slack time in the evenings, weekends and time off and only published the code on the off chance that someone else could benefit from it.  If you don't see the benefit, my apologies, there's a million other themes out there to choose from -- find one that works and ditch this one.

Provide any actual errors that are displayed (adding `set -x` in the function that the error occurs in and providing that output really helps, too).

If you *really* want to see something fixed and *really* cannot find anyone else to do it, reach out -- I don't intend on accepting donations for such a silly project, but I'm willing to help a fellow developer out if met with a kind request.
