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
ASSETSPATH="../lib/assets"

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
    DIRSTOREMOVE=(
    "*/svg/design"
    "svg/design"
    "*/drawable-xxxhdpi"
    "*/drawable-xxhdpi"
    "*/drawable-xhdpi"
    "*/drawable-mdpi"
    "*/drawable-hdpi"
    "*/3x_ios"
    #"*/2x_web"
    "*/2x_ios"
    "*/1x_web"
    "*/1x_ios"
    )

    for DIR in ${DIRSTOREMOVE[@]}; do
        log "Remove ${DIR}..."
        rm -rf "${ASSETSPATH}/${DIR}"
    done
    echo "Unnecessary files remove!"
}

generate() {
    COLORNAME="white"
    COLORCODE="#ffffff"

    _cleanup

    FILES=`find . -iname "*px.svg"`
    for FILE in $FILES; do
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
    COLORNAME="white"
    COLORCODE="#ffffff"
    MAINSASS="svg-icons.scss"
    UTILSSASS="svg-utils.scss"
    SAMPLESASS="svg-sample.scss"
    SAMPLEHTML="index.html"
    PATHTOCHECLK="${ASSETSPATH}/alert"
    PATHTOCHECLK="${ASSETSPATH}"

    _cleanup
    rm -f "${ASSETSPATH}/index.html" "${ASSETSPATH}/main.css" "${ASSETSPATH}/svg-icons.scss" "${ASSETSPATH}/svg-sample.scss"
    #rm -f ${MAINSASS}
    #rm -f ${SAMPLESASS}
    #rm -f ${SAMPLEHTML}

    TMPFILE=".temp-svg.tmp"

    # SAMPLE - BASISFARBE
    echo "@import '${MAINSASS}';" >> "${ASSETSPATH}/${SAMPLESASS}"
    echo "@import '${UTILSSASS}';" >> "${ASSETSPATH}/${SAMPLESASS}"
    echo -e "\$icon-color: \%23666666 !default;\n" >> "${ASSETSPATH}/${SAMPLESASS}"
    #echo -e "\$icon-alpha: 1 !default;\n" >> "${ASSETSPATH}/${SAMPLESASS}"
    #echo -e "\$icon-color-internal: rgba(red(\$icon-color),green(\$icon-color),blue(\$icon-color),\$icon-alpha) !default;\n" >> "${ASSETSPATH}/${SAMPLESASS}"

    prefixhtml "${ASSETSPATH}/${SAMPLEHTML}"

    FILES=`find ${PATHTOCHECLK} -iname "*px.svg"`
    for FILE in $FILES; do
        FILE="`echo ${FILE} | sed s#${ASSETSPATH}/##g`"

        FILEWITHOUTEXT=${FILE%*.*}
        PUREFILENAME=`basename ${FILE%*.*}`
        SASSFILE=${FILEWITHOUTEXT}.scss

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

        #SIZE="`echo ${PUREFILENAME} | sed s/3d//g`"
        #SIZE="`echo ${SIZE} | sed s/[^0-9]*//g`"

        FALLBACKBLACK="${PNGFILE}_black_${SIZE}dp.png"
        FALLBACKGREY="${PNGFILE}_grey600_${SIZE}dp.png"
        FALLBACKWHITE="${PNGFILE}_white_${SIZE}dp.png"
        FALLBACKSVG="`echo ${FILE} | sed s#^\./##`"

        log ${FILEWITHOUTEXT}
        log ${PUREFILENAME}
        log ${PNGFILE}
        log ${SIZE}
        log ${FALLBACKBLACK}
        log ${FALLBACKSVG}

        if [ -f "${FALLBACKBLACK}" ];then
            log "${FALLBACKBLACK} available..."
        fi
        if [ -f "${FALLBACKGREY}" ];then
            log "${FALLBACKGREY} available..."
        fi
        if [ -f "${FALLBACKWHITE}" ];then
            log "${FALLBACKWHITE} available..."
        fi


        if [ -f "${ASSETSPATH}/${SASSFILE}" ];then
            rm -f "${ASSETSPATH}/${SASSFILE}"
            log "${SASSFILE} deleted.."
        fi

        echo "   Preparing: ${SASSFILE}, size: ${SIZE}..."
        rm -f ${TMPFILE}

        sed "s/<path d=/<path fill=\"\' + \$fillColor + \'\" d=/" "${ASSETSPATH}/${FILE}" > ${TMPFILE}

        log "${SASSFILE} created!"

        echo "@function svg-${PUREFILENAME}(\$fillColor) {" > "${ASSETSPATH}/${SASSFILE}"
        #echo "       \$temp: str-replace(\$fillColor,\"#\",\"%23\");" >> "${SASSFILE}"
        echo -n "    @return url('data:image/svg+xml," >> "${ASSETSPATH}/${SASSFILE}"
        tr -d "\n" < ${TMPFILE} >> "${ASSETSPATH}/${SASSFILE}"
        echo -n "');" >> "${ASSETSPATH}/${SASSFILE}"
        echo -e "\n}" >> "${ASSETSPATH}/${SASSFILE}"

        # SASS mit allen IMPORTS
        echo "@import '${FILEWITHOUTEXT}';" >> "${ASSETSPATH}/${MAINSASS}"

        # SAMPLE - definiert HGs
        echo ".bg-${PUREFILENAME} {" >> "${ASSETSPATH}/${SAMPLESASS}"
        echo "     @include svg-background(\"${SIZE}px\");" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-repeat: no-repeat;" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-size: 100% 100%;" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-size: contain;" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-position: 50% 50%;" >> "${ASSETSPATH}/${SAMPLESASS}"
        echo "     @include svg-fallback(\"${FALLBACKSVG}\",\"${FALLBACKBLACK}\",\"${FALLBACKWHITE}\",\"${FALLBACKGREY}\");" >> "${ASSETSPATH}/${SAMPLESASS}"

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

        echo "     background-image: svg-${PUREFILENAME}(\$icon-color);" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "     background-image: svg-${PUREFILENAME}(rgba(red(\$icon-color),green(\$icon-color),blue(\$icon-color),\$icon-alpha));" >> "${ASSETSPATH}/${SAMPLESASS}"
        echo -e "}\n" >> "${ASSETSPATH}/${SAMPLESASS}"

        #echo "      @-moz-document url-prefix() { .bg-${PUREFILENAME} {" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo "            background-image: url(${FALLBACKSVG});" >> "${ASSETSPATH}/${SAMPLESASS}"
        #echo -e "     }}\n" >> "${ASSETSPATH}/${SAMPLESASS}"


        echo "    <div class=\"svgbg\">" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "        <div class=\"bg-${PUREFILENAME} svg-size-${SIZE} svg-bg onclick-menu\" tabindex=\"0\">" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "            <div class=\"onclick-menu-content\">"  >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "              <div class=\"filename\">_material-icons.scss:</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                <div class=\"import\">@import 'packages/material_icons/assets/${FILEWITHOUTEXT}';</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                  <div class=\"cssclass\">.bg-${PUREFILENAME} {</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                     <div class=\"props\">@include svg-background(\"${SIZE}\");</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                     <div class=\"props\">@include svg-fallback(\"${FALLBACKSVG}\",\"${FALLBACKBLACK}\",\"${FALLBACKWHITE}\",\"${FALLBACKGREY}\");</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                     <div class=\"props\">background-image: svg-${PUREFILENAME}(\$icon-color);</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                  <div class=\"close-cssclass\">}</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "              <br>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "              <div class=\"filename\">index.html:</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "                <div class=\"html\">&lt;div class=&quot;bg-${PUREFILENAME} svg-size-${SIZE} svg-bg&quot;&gt;&lt;/div&gt;</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "            </div>"  >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "        </div>"  >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "        <div class=\"name\">${PUREFILENAME}</div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
        echo "    </div>" >> "${ASSETSPATH}/${SAMPLEHTML}"
    done
    postfixhtml "${ASSETSPATH}/${SAMPLEHTML}"
    rm -f ${TMPFILE}

    sassc "${ASSETSPATH}/main.scss" "${ASSETSPATH}/main.css" && autoprefixer "${ASSETSPATH}/main.css"
    echo -e "\nmain.css generated, you are ready to go!"
}

prefixhtml() {
    HTMLFILE=$1

    echo "<!doctype html>" >> ${HTMLFILE}
    echo "<html lang="en-US">" >> ${HTMLFILE}
    echo "<head>" >> ${HTMLFILE}
    echo "<meta charset=\"UTF-8\">" >> ${HTMLFILE}
    echo "<title></title>" >> ${HTMLFILE}
    #echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"svg-sample.css\"/>" >> ${HTMLFILE}
    echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"main.css\"/>" >> ${HTMLFILE}
    echo "<style>" >> ${HTMLFILE}
    #echo "    .svgbg:after { content: '-'; }"  >> ${HTMLFILE}
    echo "</style>" >> ${HTMLFILE}

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
        echo ${STRINGTOLOG}
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