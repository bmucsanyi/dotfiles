# Load direnv, Act I
emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load direnv, Act II
emulate zsh -c "$(direnv hook zsh)"

# Python cleanup function
pyclean () {
    find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
}

# Source p10k theme
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# Completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Change autosuggest-accept from right arrow to double tab
# bindkey '\t\t' autosuggest-accept

# Initialize completion system
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
autoload -Uz compinit && compinit

# Initialize syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Use Eza instead of ls
alias ls="eza --icons=never"

# Add SSH and SSHFS aliases
alias ssh_mlcloud="ssh -i ~/.ssh/slurm_tue owl569@134.2.168.43 -p 2221"
alias sshfs_mlcloud="umount -f ~/mnt/mlcloud &> /dev/null; sshfs -p 2221 -o IdentityFile=~/.ssh/slurm_tue owl569@134.2.168.114:/mnt/lustre/work/hennig/owl569 ~/mnt/mlcloud"
