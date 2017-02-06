#
# No plugin manager is needed to use this file. All that is needed is adding:
#   source {where-zcommodore-is}/zcommodore.plugin.zsh
#
# to ~/.zshrc.
#

0="${(%):-%N}" # this gives immunity to functionargzero being unset
ZGDBM_REPO_DIR="${0%/*}"
ZGDBM_CONFIG_DIR="$HOME/.config/zgdbm"

#
# Update FPATH if:
# 1. Not loading with Zplugin
# 2. Not having fpath already updated (that would equal: using other plugin manager)
#

if [[ -z "$ZPLG_CUR_PLUGIN" && "${fpath[(r)$ZGDBM_REPO_DIR]}" != $ZGDBM_REPO_DIR ]]; then
    fpath+=( "$ZGDBM_REPO_DIR" )
fi

[[ -z "${fg_bold[green]}" ]] && builtin autoload -Uz colors && colors

#
# Compile the module
#

if [ ! -e "${ZGDBM_REPO_DIR}/module/Src/Modules/db_gdbm.so" ]; then
    builtin print "----------------------------"
    builtin print "${fg_bold[magenta]}psprint${reset_color}/${fg_bold[yellow]}zgdbm${reset_color} is building..."
    builtin print "----------------------------"
    ( builtin cd "${ZGDBM_REPO_DIR}/module"; [[ ! -e Makefile ]] && ./configure )
    command make -C "${ZGDBM_REPO_DIR}/module"

    () {
        local ts="${EPOCHSECONDS}"
        [[ -z "$ts" ]] && ts="$( date +%s )"
        builtin echo "$ts" >! "${ZGDBM_REPO_DIR}/module/COMPILED_AT"
    }
elif [[ ! -f "${ZGDBM_REPO_DIR}/module/COMPILED_AT" || ( "${ZGDBM_REPO_DIR}/module/COMPILED_AT" -ot "${ZGDBM_REPO_DIR}/module/RECOMPILE_REQUEST" ) ]]; then
    () {
        # Don't trust access times and verify hard stored values
        [[ -e ${ZGDBM_REPO_DIR}/module/COMPILED_AT ]] && local compiled_at_ts="$(<${ZGDBM_REPO_DIR}/module/COMPILED_AT)"
        [[ -e ${ZGDBM_REPO_DIR}/module/RECOMPILE_REQUEST ]] && local recompile_request_ts="$(<${ZGDBM_REPO_DIR}/module/RECOMPILE_REQUEST)"

        if [[ "${recompile_request_ts:-1}" -gt "${compiled_at_ts:-0}" ]]; then
            builtin echo "${fg_bold[red]}SINGLE RECOMPILETION REQUESTED BY PLUGIN'S (ZGDBM) UPDATE${reset_color}"
            ( builtin cd "${ZGDBM_REPO_DIR}/module"; ./configure )
            command make -C "${ZGDBM_REPO_DIR}/module" clean
            command make -C "${ZGDBM_REPO_DIR}/module"

            local ts="${EPOCHSECONDS}"
            [[ -z "$ts" ]] && ts="$( date +%s )"
            builtin echo "$ts" >! "${ZGDBM_REPO_DIR}/module/COMPILED_AT"
        fi
    }
fi
