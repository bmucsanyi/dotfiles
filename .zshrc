# Python cleanup function
pyclean () {
    find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
}

# Load direnv
eval "$(direnv hook zsh)"

# Initialize completion system
autoload -Uz compinit && compinit

