#!/bin/bash
##################################################################
#
# Erstellt weiße SVG-Files
#
##################################################################

APPNAME="gensvg.sh"

#------------------------------------------------------------------------------
# BASIS

#LOGFILE="${APPNAME}_`date +"%Y%m%d"`.log"


#------------------------------------------------------------------------------
# Lock wird gesetzt
LOCKDIR="/var/lock"
LOCKFILE="$LOCKDIR/$APPNAME.lock"

[ -f ${LOCKFILE} ] && exit 0
trap 'cleanup' EXIT TERM INT

cleanup () {
    rm -f ${LOCKFILE};
    exit 255;
    }
    
touch ${LOCKFILE}

#------------------------------------------------------------------------------
# Read settings from settings-file
#
SETTINGS_FILE=$APPNAME.conf
SETTINGS_USER="~/.$SETTINGS_FILE"
SETTINGS_ETC="/etc/$SETTINGS_FILE"

if test -e $SETTINGS_USER
then
    . $SETTINGS_USER
elif test -e $SETTINGS_ETC
then
    . $SETTINGS_ETC
fi

DEBUG=false
DEBUG=true

#------------------------------------------------------------------------------
# Functions
#

sampleFunction() {
	PARAM1=$1

	if test "$PARAM1" != ""
	then
	    echo "Param1: $PARAM1"
	else
	    echo "Param1 not set..."
	fi

	for SUBFOLDER in "${SASSFILES[@]}"
	do
		echo -e "\tSubfolder: ${SUBFOLDER}"
	done
}  

_cleanup() {
    ASSETSPATH="../lib/assets"

    DIRSTOREMOVE=(
    "*/svg/design"
    "svg/design"
    "*/drawable-xxxhdpi"
    "*/drawable-xxhdpi"
    "*/drawable-xhdpi"
    "*/drawable-mdpi"
    "*/drawable-hdpi"
    "*/3x_ios"
    "*/2x_web"
    "*/2x_ios"
    "*/1x_web"
    "*/1x_ios"
    )

    for DIR in ${DIRSTOREMOVE[@]}; do
        log "Remove ${ASSETSPATH}/${DIR}..."
        rm -rf "${ASSETSPATH}/${DIR}"
    done
    echo "Unnecessary files remove!"
}

generate() {
    COLORNAME="white"
    COLORCODE="#ffffff"

    _cleanup

    FILES=`find . -iname "*px.svg"`
    for FILE in ${FILES}; do
        FILEWITHOUTEXT=${FILE%*.*}
        COLORFILE="${FILEWITHOUTEXT}-${COLORNAME}.svg"

        if [ -f "${COLORFILE}" ];then
            rm -f ${COLORFILE}
            echo "${COLORFILE} deleted.."
        fi

        echo "${FILEWITHOUTEXT}-${COLORNAME}.svg created!"
        sed "s/<path d=/<path fill=\"${COLORCODE}\" d=/" ${FILEWITHOUTEXT}.svg > ${FILEWITHOUTEXT}-${COLORNAME}.svg;
    done

    echo "Now you can generate your css/scss with './gencss.sh --icons'"
}

gensass() {
    ASSETSPATH="../assets"
    SRCPATH="${ASSETSPATH}/action"
    SRCPATH="${ASSETSPATH}"
    TARGETPATH="../lib/sass"

    SVGICONS="svg-icons.scss"
    SVGUTILS="svg-utils.scss"
    SVGSAMPLES="svg-sample.scss"
    INDEXHTML="index.html"

    _cleanup
    rm -f "${TARGETPATH}/index.html" "${TARGETPATH}/main.css" "${TARGETPATH}/svg-icons.scss" "${TARGETPATH}/svg-sample.scss"
    #rm -f ${MAINSASS}
    #rm -f ${SAMPLESASS}
    #rm -f ${SAMPLEHTML}

    TMPFILE=".temp-svg.tmp"

    # SAMPLE - BASISFARBE
    echo "@import '${SVGICONS}';" >> "${TARGETPATH}/${SVGSAMPLES}"
    echo "@import '${SVGUTILS}';" >> "${TARGETPATH}/${SVGSAMPLES}"
    echo -e "\$icon-color: #666666 !default;\n" >> "${TARGETPATH}/${SVGSAMPLES}"
    #echo -e "\$icon-alpha: 1 !default;\n" >> "${ASSETSPATH}/${SAMPLESASS}"
    #echo -e "\$icon-color-internal: rgba(red(\$icon-color),green(\$icon-color),blue(\$icon-color),\$icon-alpha) !default;\n" >> "${ASSETSPATH}/${SAMPLESASS}"

    prefixhtml "${TARGETPATH}/${INDEXHTML}"

    FILES=`find ${SRCPATH} -iname "*px.svg"`
    for FILE in $FILES; do
        FILE="`echo ${FILE} | sed s#${TARGETPATH}/##g`"

        FILEWITHOUTEXT=${FILE%*.*}
        FILENAME=`basename ${FILE}`
        FILEPATH="`echo ${FILE} | sed s/${FILENAME}//`"
        PUREFILENAME=`basename ${FILE%*.*}`

        SASSFILE=${PUREFILENAME}.scss
        SASSPATH="`echo ${FILEPATH} | sed s#^\.\./assets/##`"
        SASSPATH="${TARGETPATH}/${SASSPATH}";
        SASSTOIMPORT="`echo ${FILEWITHOUTEXT} | sed s#^\.\./assets/##`"

        PNGFILE="`echo ${FILEWITHOUTEXT} | sed s#/svg/#/2x_web/#g`"
        PNGFILE="`echo ${PNGFILE} | sed s/_18px//g`"
        PNGFILE="`echo ${PNGFILE} | sed s/_24px//g`"
        PNGFILE="`echo ${PNGFILE} | sed s/_36px//g`"
        PNGFILE="`echo ${PNGFILE} | sed s/_48px//g`"
        PNGFILE="`echo ${PNGFILE} | sed s#production/##g`"
        PNGFILE="`echo ${PNGFILE} | sed s#^\./##`"

        if [[ ${PUREFILENAME} =~ .*24px.* ]]
        then
            SIZE="24"
        fi
        if [[ ${PUREFILENAME} =~ .*48px.* ]]
        then
            SIZE="48"
        fi
        if [[ ${PUREFILENAME} =~ .*36px.* ]]
        then
            SIZE="36"
        fi
        if [[ ${PUREFILENAME} =~ .*18px.* ]]
        then
            SIZE="18"
        fi

        FALLBACKBLACK="${PNGFILE}_black_${SIZE}dp.png"
        FALLBACKGREY="${PNGFILE}_grey600_${SIZE}dp.png"
        FALLBACKWHITE="${PNGFILE}_white_${SIZE}dp.png"
        FALLBACKSVG="`echo ${FILE} | sed s#^\./##`"

        FALLBACKBLACK="`echo ${FALLBACKBLACK} | sed s#^\.\./assets/##`"
        FALLBACKGREY="`echo ${FALLBACKGREY} | sed s#^\.\./assets/##`"
        FALLBACKWHITE="`echo ${FALLBACKWHITE} | sed s#^\.\./assets/##`"
        FALLBACKSVG="`echo ${FALLBACKSVG} | sed s#^\.\./assets/##`"

        log "--------------------------------------------------------------"
        log "Filepath:           ${FILEPATH}"
        log "File without Ext:   ${FILEWITHOUTEXT}"
        log "Pure Filename:      ${PUREFILENAME}"
        log "SASSFile:           ${SASSFILE}"
        log "SASSPath:           ${SASSPATH}"
        log "SassToImport:       ${SASSTOIMPORT}"
        log "PNG-File:           ${PNGFILE}"
        log "Size:               ${SIZE}"
        log "SrcPath:            ${SRCPATH}"
        log "File:               ${FILE}"
        log "FallbackBlack       ${FALLBACKBLACK}"
        log "FallbackGrey        ${FALLBACKGREY}"
        log "FallbackWhite       ${FALLBACKWHITE}"
        log "FallbackSVG         ${FALLBACKSVG}"
        log "--------------------------------------------------------------\n"

        if [ -f "../${FALLBACKBLACK}" ];then
            log "FallbackBlack: ${FALLBACKBLACK} available..."
        fi
        if [ -f "../${FALLBACKGREY}" ];then
            log "FallbackGrey: ${FALLBACKGREY} available..."
        fi
        if [ -f "../${FALLBACKWHITE}" ];then
            log "FallbackWhite: ${FALLBACKWHITE} available..."
        fi
        if [ -f "../${FALLBACKSVG}" ];then
            log "FallbackSVG: ${FALLBACKSVG} available..."
        fi
        log "--------------------------------------------------------------\n"

        if [ ! -d "${SASSPATH}" ]; then
            mkdir -p ${SASSPATH}
        fi

        if [ -f "${SASSPATH}/${SASSFILE}" ];then
            rm -f "${SASSPATH}/${SASSFILE}"
            log "${SASSFILE} deleted.."
        fi

        echo "Preparing: ${SASSFILE}, size: ${SIZE}..."
        rm -f ${TMPFILE}

        sed "s/<path d=/<path fill=\"\' + \$fillColor + \'\" d=/" "${FILE}" > ${TMPFILE}

        log "Sassfile: ${SASSFILE} created!"

        echo "@function svg-${PUREFILENAME}(\$fillColor) {" > "${SASSPATH}/${SASSFILE}"
        # BASE64
        #echo -n "    @return url('data:image/svg+xml;charset=utf-8;base64,' + base64Encode('" >> "${SASSPATH}/${SASSFILE}"

        # URLENCODE
        echo -n "    @return url('data:image/svg+xml;charset=utf-8,' + urlencode('" >> "${SASSPATH}/${SASSFILE}"
            tr -d "\n" < ${TMPFILE} >> "${SASSPATH}/${SASSFILE}"
        echo -n "'));" >> "${SASSPATH}/${SASSFILE}"

        echo -e "\n}" >> "${SASSPATH}/${SASSFILE}"

        # SASS mit allen IMPORTS
        echo "@import '${SASSTOIMPORT}';" >> "${TARGETPATH}/${SVGICONS}"

        # SAMPLE - definiert HGs
        echo ".bg-${PUREFILENAME} {" >> "${TARGETPATH}/${SVGSAMPLES}"
        echo "     @include svg-background(\"${SIZE}px\");" >> "${TARGETPATH}/${SVGSAMPLES}"
        #echo "     background-repeat: no-repeat;" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-size: 100% 100%;" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-size: contain;" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-position: 50% 50%;" >> "${ASSETSPATH}/${SAMPLESASS}"
        echo "     @include svg-fallback(\"${FALLBACKSVG}\",\"${FALLBACKBLACK}\",\"${FALLBACKWHITE}\",\"${FALLBACKGREY}\");" >> "${TARGETPATH}/${SVGSAMPLES}"

        #echo "     .no-svg & {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "         &.fallback-black {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "             background-image: url(${FALLBACKBLACK});" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "         }\n" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "         &.fallback-white {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "             background-image: url(${FALLBACKWHITE});" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "         }\n" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "         &.fallback-grey {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "             background-image: url(${FALLBACKGREY});" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "         }\n" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "     }\n" >> "${ASSETSPATH}/${SAMPLESASS}"
        #
        #echo "      .svg-not-inline & {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "            background-image: url(${FALLBACKSVG});" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "     }\n" >> "${ASSETSPATH}/${SAMPLESASS}"

        echo "     background-image: svg-${PUREFILENAME}(\$icon-color);" >> "${TARGETPATH}/${SVGSAMPLES}"
        #echo "     background-image: svg-${PUREFILENAME}(rgba(red(\$icon-color),green(\$icon-color),blue(\$icon-color),\$icon-alpha));" >> "${ASSETSPATH}/${SAMPLESASS}"
        echo -e "}\n" >> "${TARGETPATH}/${SVGSAMPLES}"

        #echo "      @-moz-document url-prefix() { .bg-${PUREFILENAME} {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "            background-image: url(${FALLBACKSVG});" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "     }}\n" >> "${ASSETSPATH}/${SAMPLESASS}"


        echo "    <div class=\"svgbg\">" >> "${TARGETPATH}/${INDEXHTML}"
        echo "        <div class=\"bg-${PUREFILENAME} svg-size-${SIZE} svg-bg onclick-menu\" tabindex=\"0\">" >> "${TARGETPATH}/${INDEXHTML}"
        echo "            <div class=\"onclick-menu-content\">"  >> "${TARGETPATH}/${INDEXHTML}"
        echo "              <div class=\"filename\">_material-icons.scss:</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                <div class=\"import\">@import 'packages/material_icons/sass/${SASSTOIMPORT}';</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                  <div class=\"cssclass\">.bg-${PUREFILENAME} {</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                     <div class=\"props\">@include svg-background(\"${SIZE}\");</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                     <div class=\"props\">@include svg-fallback(\"${FALLBACKSVG}\",\"${FALLBACKBLACK}\",\"${FALLBACKWHITE}\",\"${FALLBACKGREY}\");</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                     <div class=\"props\">background-image: svg-${PUREFILENAME}(\$icon-color);</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                  <div class=\"close-cssclass\">}</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "              <br>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "              <div class=\"filename\">index.html:</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "                <div class=\"html\">&lt;div class=&quot;bg-${PUREFILENAME} svg-size-${SIZE} svg-bg&quot;&gt;&lt;/div&gt;</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "            </div>"  >> "${TARGETPATH}/${INDEXHTML}"
        echo "        </div>"  >> "${TARGETPATH}/${INDEXHTML}"
        echo "        <div class=\"name\">${PUREFILENAME}</div>" >> "${TARGETPATH}/${INDEXHTML}"
        echo "    </div>" >> "${TARGETPATH}/${INDEXHTML}"
    done
    postfixhtml "${TARGETPATH}/${INDEXHTML}"
    rm -f ${TMPFILE}

    #sassc "${ASSETSPATH}/main.scss" "${ASSETSPATH}/main.css" && autoprefixer "${ASSETSPATH}/main.css"
    sass "${TARGETPATH}/main.scss" "${TARGETPATH}/main.css" -r "../lib/sassext/urlencode.rb" && autoprefixer "${TARGETPATH}/main.css"

    echo -e "\nmain.css generated, you are ready to go!"

}

prefixhtml() {
    HTMLFILE=$1

    echo "<!doctype html>" >> ${HTMLFILE}
    echo "<html lang="en-US">" >> ${HTMLFILE}
    echo "<head>" >> ${HTMLFILE}
    echo "<title>Material Icons</title>" >> ${HTMLFILE}
    echo "<meta charset=utf-8>" >> ${HTMLFILE}
    echo "<meta http-equiv=X-UA-Compatible content="IE=edge">" >> ${HTMLFILE}
    echo "<meta name=description content="Helper to select the right import for material-icons">" >> ${HTMLFILE}
    echo "<meta name=viewport content="width=device-width, initial-scale=1">" >> ${HTMLFILE}
    echo "<meta name=mobile-web-app-capable content=yes>" >> ${HTMLFILE}
    echo "<meta name=apple-mobile-web-app-capable content=yes>" >> ${HTMLFILE}
    echo "<meta name=apple-mobile-web-app-status-bar-style content=black>" >> ${HTMLFILE}
    echo "<meta name=apple-mobile-web-app-title content="Material Icons">" >> ${HTMLFILE}

    echo "<link rel="stylesheet" type="text/css" href="main.css"/>" >> ${HTMLFILE}

    echo "</head>" >> ${HTMLFILE}
    echo "<body>" >> ${HTMLFILE}
}

postfixhtml() {
    HTMLFILE=$1
    echo "</body>" >> ${HTMLFILE}
    echo "</html>" >> ${HTMLFILE}
}

log() {
    STRINGTOLOG=$1

    if [ "${DEBUG}" = true ] ; then
        echo -e ${STRINGTOLOG}
    fi
}

#------------------------------------------------------------------------------
# Options
#

usage()
    {
    echo
    echo "Usage: `basename $0` [ options ]"
    echo -e "\t--gen    Generate white SVG-Files"
    echo -e "\t--sass   Generate white SASS-Files"
    echo
    }


case "$1" in 
    help|-help|--help)
	    usage
	;;
	
    sample|-sample|--sample)
	    sampleFunction "Hallo"
	;;

    gen|-gen|--gen)
	    generate
	;;

    sass|-sass|--sass)
        gensass
    ;;

*)
    usage
	;;

esac    

#------------------------------------------------------------------------------
# Alles OK...

exit 0