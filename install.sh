#!/bin/bash

function npmInit {
  if [ -e ./package.json ]; then
    echo 'package.json already exists'
  else
    echo '{
  "name": "@upstatement/project-name",
  "version": "0.0.0",
  "description": "",
  "keywords": [],
  "author": "",
  "license": "",
  "main": "",
  "scripts": {},
  "dependencies": {},
  "devDependencies": {}
}' > package.json
  fi
}

function gitInit {
  if [ -e .git ]; then
    echo 'Already a git repository'
  else
    eval "git init --initial-branch=main"
    eval "touch .gitignore"
    echo '/node_modules
.DS_Store
' > .gitignore
  fi
}

function addHooks {
  echo ""
  read -p "Do you want to use pre-commit hooks? (y/n) " choice
  case "$choice" in
    y|Y )
      echo ""
      echo "Making sure the latest version on npm is installed..."

      eval "npm install -g npm@latest"

      # Initialize git if needed
      gitInit

      echo ""
      echo "Installing husky and lint-staged packages..."

      eval "npm install -D husky lint-staged"

      eval "npm set-script prepare 'husky install' && npm run prepare"

      eval "npm set-script lint-staged 'lint-staged'"

      eval "npx husky add .husky/pre-commit 'npm run lint-staged'"

      INSERT_HERE=$(( $(wc -l < package.json) - 1 ))

      # add pre-commit hook configs to package.json
      eval "head -n $INSERT_HERE package.json > temp.txt"

      eval "sed '$INSERT_HERE s/$/,/' temp.txt > temp2.txt"

      echo '  "lint-staged": {
    "*.{js,css,json,md}": [
      "prettier --write"
    ],
    "*.js": [
      "eslint --fix"
    ]
  }
}' >> temp2.txt

      eval "mv temp2.txt package.json && rm temp.txt"
      ;;
    n|N )
      echo ''
      ;;
    * )
  esac
}

SPACING=2

function scaffold {
  # create files
  eval "touch .editorconfig prettier.config.js .eslintrc"

  # init package.json
  npmInit

  if [ -z "$1" ]; then
    eval "npx install-peerdeps --dev @upstatement/eslint-config"

    eval "npm install --save-dev @upstatement/prettier-config"

    echo '{
  "root": true,
  "extends": "@upstatement",
  "parserOptions": {
    "sourceType": "module"
  },
  "env": {
    "browser": true,
    "node": true
  }
}' > .eslintrc

  elif [ $1 = four ]; then

    eval "npx install-peerdeps --dev @upstatement/eslint-config"

    eval "npm install --save-dev @upstatement/prettier-config"

    echo '{
  "root": true,
  "extends": "@upstatement/eslint-config/four-spaces",
  "parserOptions": {
    "sourceType": "module"
  },
  "env": {
    "browser": true,
    "node": true
  }
}' > .eslintrc

    SPACING=4

  elif [ $1 = react ]; then

    eval "npx install-peerdeps --dev @upstatement/eslint-config"

    eval "npm install --save-dev @upstatement/prettier-config eslint-plugin-react eslint-plugin-jsx-a11y @babel/preset-react"

    eval "touch .babelrc"

    echo '{
  "root": true,
  "extends": "@upstatement/eslint-config/react"
}' > .eslintrc

    echo '   {
  "presets": [
    "@babel/preset-react"
  ]
}' > .babelrc

  elif [ $1 = vue ]; then

    eval "npx install-peerdeps --dev @upstatement/eslint-config"

    eval "npm install --save-dev @upstatement/prettier-config eslint-plugin-vue vue-eslint-parser"

    echo '{
  "root": true,
  "extends": "@upstatement/eslint-config/vue"
}' > .eslintrc

  else
    echo 'Uh oh something went wrong'
  fi

  echo "root = true

[*]
charset = utf-8
indent_style = space
indent_size = $SPACING
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true" > .editorconfig

  if [ $SPACING = 4 ]; then
    echo "module.exports = require('@upstatement/prettier-config/four-spaces');" > prettier.config.js
  else
    echo "module.exports = require('@upstatement/prettier-config');" > prettier.config.js
  fi

  addHooks
}

# Default config
if [ -z "$1" ]; then
  echo 'Setting up default linting configs...'
  scaffold

# Four spaces config
elif [ $1 = four ]; then
  echo "Setting up four spaces linting config..."
  scaffold four

# React config
elif [ $1 = react ]; then
  echo "Setting up react linting config..."
  scaffold react

# Vue Config
elif [ $1 = vue ]; then
  echo "Setting up vue linting config..."
  scaffold vue

else
  echo 'Please specify a valid config, such as `react` or `vue`'
fi
