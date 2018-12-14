#!/bin/zsh
ls *.zsh */**/*.zsh | entr -pc ./refrezsh.plugin.zsh print debug
