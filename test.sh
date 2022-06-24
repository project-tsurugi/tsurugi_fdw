#!/bin/bash

# Fix below
LOCAL=$HOME/.local
# Fix above

${LOCAL}/bin/oltp shutdown
${LOCAL}/bin/oltp start

make installcheck
