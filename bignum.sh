#!/bin/bash - 
#===============================================================================
#
#          FILE:  bignum.sh
# 
#   DESCRIPTION:  Pure bash implementation of Bignum
# 
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Ess (ess), pooster@gmail.com
#       CREATED: 06/09/10 10:46:15 EDT
#      REVISION:  ---
#===============================================================================

#-------------------------------------------------------------------------------
#    Bash Bignum - A pure Bash implementation of Bignum
#    Copyright (C) 2010 Ess
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------

BN_MINUS='-'
BN_PLUS='+'
BN_0='+|0'
BN_1='+|1'

int_max() {
  [ "${1}" -gt "${2}" ] && echo -n "${1}" || echo -n "${2}"
}

bn_abs() {
  local n="$( bn_sanitize "${1}" )"

  local bgarray=( $(bn_digits "${n}" ) )
  echo -n "+|${bgarray[*]}"
}

bn_negate() {
  local n="$( bn_sanitize "${1}" )"
  local bgarray=( $( bn_digits "${n}" ) )
  local s=$( bn_sign "${n}")

  [ "${s}" == ${BN_PLUS} ] && s="${BN_MINUS}" || s="${BN_PLUS}"

  echo -n "${s}|${bgarray[*]}"
}

bn_size() {
  local n="$( bn_sanitize "${1}" )"

  local nDigits=( $( bn_digits "${n}" ) )

  echo -n "${#nDigits[@]}"
}

bn_sign() {
  local bg="${1}"
  local sign="${bg%%|*}"
  
  echo -n "${sign}"
}

bn_digits() {
  local bg="${1}"

  echo -n "${bg#*|}"
}

bn_append() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"
  local aSign="$( bn_sign "${a}" )"
  local aDigits="$( bn_digits "${a}" )"
  local bDigits="$( bn_digits "${b}" )"

  echo -n "${aSign}|${bDigits} ${aDigits}"
}

bn_prepend() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"
  local aSign="$( bn_sign "${a}" )"
  local aDigits="$( bn_digits "${a}" )"
  local bDigits="$( bn_digits "${b}" )"

  echo -n "${aSign}|${aDigits} ${bDigits}"
}

bn_lastdigit() {
  local n="$( bn_sanitize "${1}" )"
  local s="$( bn_size "${n}" )"

  echo -n $(( s - 1 ))
}

bn_sanitize() {
  local n="${1}"
  local nSign="$( bn_sign "${n}" )"
  local nDigits=( $( bn_digits "${n}" ) )

  while [ ${#nDigits[@]} -gt 1 ] && [ ${nDigits[$(( ${#nDigits[*]} - 1))]} -eq 0 ] 
  do
    unset nDigits[$(( ${#nDigits[*]} - 1))]
  done

  [ ${#nDigits[*]} -eq 1 ] &&
  [ "${nDigits[0]}" -eq 0 ] &&
  nSign='+'

  echo -n "${nSign}|${nDigits[*]}"
}

bn_to_string() {
  local n="$( bn_sanitize "${1}" )"
  local sign="$( bn_sign "${n}" )"
  local digits=( $( bn_digits "${n}" ) )
  local lastdigit="$( bn_lastdigit "${n}" )"
  local i=''
  local result=''
  [ "${sign}" == '-' ] && result="${sign}"
  
  for ((i=lastdigit; i>=0; i--))
  do
    result="${result}${digits[$i]}"
  done
  echo -n $result
}

bn_create() {
  local s="${1}"
  local sign='+'
  local lastdigit='0'
  local len=${#s}
  (( len-- ))
  declare -a digits

  local c=''
  local count=0
  local index=''

  for ((c=len; c>0; c-- ))
  do
    digits[${#digits[@]}]=${s:${c}:1}
  done

  
  if [ "${s:0:1}" == '-' ] || [ "${s:0:1}" == '+' ]
  then
    sign="${s:0:1}"
  else
    digits[${#digits[@]}]=${s:0:1}
  fi
  bn_sanitize "${sign}|${digits[*]}"
}

bn_larger() {
  bn_gt "${1}" "${2}" && echo -n "${1}" || echo -n "${2}"
}

bn_smaller() {
  bn_lt "${1}" "${2}" && echo -n "${1}" || echo -n "${2}"
}

bn_add() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"

  local aSign="$( bn_sign "${a}" )"
  local bSign="$( bn_sign "${b}" )"
  local cSign='+'

  is_pos "${a}" && is_neg "${b}" && 
  bn_sanitize "$( bn_subtract "${a}" "$( bn_negate "${b}" )" )" && return 0
  
  is_neg "${a}" && is_neg "${b}" &&
  bn_sanitize "$( bn_negate "$( bn_add "$( bn_negate "${a}" )" "$( bn_negate "${b}" )" )" )" &&
  return 0

  is_neg "${a}" && is_pos "${b}" &&
  bn_sanitize "$( bn_subtract "${b}" "$( bn_negate "${a}" )" )" && return 0

  local carry='0'
  local aDigits=( $( bn_digits "${a}" ) )
  local bDigits=( $( bn_digits "${b}" ) )
  local lastdigit=$( int_max "${#aDigits[*]}" "${#bDigits[*]}" )
  local cDigits=()

  local i=''
  for ((i=0; i<(lastdigit + 1); i++))
  do
    local da='0'
    local db='0'
    [ -n "${aDigits[$i]}" ] && da="${aDigits[$i]}"
    [ -n "${bDigits[$i]}" ] && db="${bDigits[$i]}"
    cDigits[$i]=$(( ( carry + da + db ) % 10 ))
    carry=$(( ( carry + da + db ) / 10 ))
  done

  [ -n "${cSign}" ] || cSign='+'

  bn_sanitize "${cSign}|${cDigits[*]}"
}

is_pos() {
  [ "$( bn_sign "${1}" )" == '+' ]
}

is_neg() {
  [ "$( bn_sign "${1}" )" == '-' ]
}

is_bignum() {
  local bg="${1}"

  local sign="${bg%%|*}"

  [ "${sign}" == '-' ] || [ "${sign}" == '+' ]
}

bn_subtract() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"

  local aSign="$( bn_sign "${a}" )"
  local bSign="$( bn_sign "${b}" )"
  local cSign='+'

  is_neg "${a}" && is_pos "${b}" && 
  bn_sanitize "$( bn_negate "$( bn_add "$( bn_negate "${a}" )" "${b}" )" )" && return 0

  is_neg "${a}" && is_neg "${b}" &&
  bn_sanitize "$( bn_add "$( bn_negate "${b}" )" "${a}" )" && return 0

  is_pos "${a}" && is_neg "${b}" &&
  bn_sanitize "$( bn_add "${a}" "$( bn_negate "${b}" )" )" && return 0

  bn_gt "${b}" "${a}" && 
  bn_sanitize "$( bn_negate "$( bn_subtract "${b}" "${a}")" )" && return 0

  local aDigits=( $( bn_digits "${a}" ) )
  local bDigits=( $( bn_digits "${b}" ) )
  local lastdigit=$( int_max "${#aDigits[*]}" "${#bDigits[*]}" )
  local cDigits=()
  local borrow=0
  local i=''
  local v=''

  for ((i=0; i<=lastdigit; i++))
  do
    local da='0'
    local db='0'
    [ -n "${aDigits[$i]}" ] && da="${aDigits[$i]}"
    [ -n "${bDigits[$i]}" ] && db="${bDigits[$i]}"
    
    v=$(( da - borrow - db))
    
    [ ${da} -gt 0 ] && borrow=0
    [ ${v} -lt 0 ] && (( v += 10 )) && borrow=1
    cDigits[$i]=$(( v % 10 ))
  done

  [ -n "${cSign}" ] || cSign='+'

  bn_sanitize "${cSign}|${cDigits[*]}"
}

bn_gt() {
  local a="${1}"
  local b="${2}"

  local aSign="$( bn_sign "${a}" )"
  local bSign="$( bn_sign "${b}" )"

  [ -z "${aSign}" ] && aSign='+'
  [ -z "${bSign}" ] && bSign='+'

  [ "${aSign}" == "${BN_MINUS}" ] && [ "${bSign}" == "${BN_PLUS}" ] && return 1
  [ "${aSign}" == "${BN_PLUS}" ] && [ "${bSign}" == "${BN_MINUS}" ] && return 0

  local aDigits=( $( bn_digits "${a}" ) )
  local bDigits=( $( bn_digits "${b}" ) )

  # gt != ge
  [ "${aDigits[*]}" == "${bDigits[*]}" ] && return 1

  local aLen=${#aDigits[*]}
  local bLen=${#bDigits[*]}
  local lastdigit=$( int_max "${aLen}" "${bLen}" )
  local i=''

  if [ "${aSign}" == "${BN_PLUS}" ]
  then
    # [ "${aLen}" -gt "${bLen}" ] && return 0
    [ "${aLen}" -lt "${bLen}" ] && return 1

    for ((i=lastdigit; i>=0; i-- ))
    do
      local da=0
      local db=0
      [ -n "${aDigits[$i]}" ] && da="${aDigits[$i]}"
      [ -n "${bDigits[$i]}" ] && db="${bDigits[$i]}"
      [ "${da}" -lt "${db}" ] && return 1
      [ "${da}" -gt "${db}" ] && return 0
    done

    return 0
  else
    [ "${aLen}" -gt "${bLen}" ] && return 1

    for ((i=lastdigit; i>=0; i-- ))
    do
      local da=0
      local db=0
      [ -n "${aDigits[$i]}" ] && da="${aDigits[$i]}"
      [ -n "${bDigits[$i]}" ] && db="${bDigits[$i]}"
      [ "${da}" -gt "${db}" ] && return 1
    done

    return 0
  fi

  return 1
}

bn_eq() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"

  [ "${a}" == "${b}" ]
}

bn_ge() {
  bn_eq "${1}" "${2}" || bn_gt "${1}" "${2}"
}

bn_lt() {
  ! bn_ge "${1}" "${2}"
}

bn_le() {
  bn_eq "${1}" "${2}" || bn_lt "${1}" "${2}"
}

bn_shift() {
  local n="$( bn_sanitize "${1}" )"
  local d="${2}"

  local nSign="$( bn_sign "${n}" )"
  local nDigits=( $( bn_digits "${n}" ) )

  local i=0
  for ((i=0; i<d; i++ ))
  do
    nDigits=( 0 ${nDigits[*]} )
  done

  bn_sanitize "${nSign}|${nDigits[*]}"
}

bn_result_sign() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"
  local op="${3}"

  local aSign="$( bn_sign "${a}" )"
  [ -z "${aSign}" ] && aSign="+"
  local bSign="$( bn_sign "${b}" )"
  [ -z "${bSign}" ] && bSign="+"

  local rSign='+'
  case "${op}" in
    add)
    if bn_lt "$( bn_abs "${a}" )" "$( bn_abs "${b}" )"
    then
      is_pos "${a}" && is_pos "${b}" && rSign='-'
      is_neg "${a}" && rSign='-'
    fi
    ;;
    sub)
    true
    ;;
    mul)
    [ "${aSign}" != "${bSign}" ] && rSign='-'
    ;;
    div)
    [ "${aSign}" != "${bSign}" ] && rSign='-'
    ;;
  esac
  echo -n "${rSign}"
}

bn_multiply() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"
  local result="$( bn_create '0' )"
  local rSign="$( bn_result_sign "${a}" "${b}" "mul" )"

  # For the sake of optimal efficiency and least number of additions, let's
  # make sure the multiplicand is always the shortest of the two bignums
  [ "$(bn_size "${b}")" -gt "$( bn_size "${a}" )" ] && 
  bn_multiply "${b}" "${a}" && return 0
  
  local row="$( bn_abs "${a}" )"
  local tmp=''
  local bDigits=( $( bn_digits "${b}" ) )
  local bLastDigit="$( bn_lastdigit "${b}" )"
  local i=0
  local j=0
  for ((i=0 ; i<=bLastDigit; i++ ))
  do
    local bd=0
    [ -n "${bDigits[$i]}" ] && bd="${bDigits[$i]}"
    for ((j=1; j<=bd; j++))
    do
      result="$( bn_add "${result}" "${row}" )"
    done
    row="$( bn_shift "${row}" 1 )"
  done

  echo -n "${rSign}|$(bn_digits "${result}")"
}

bn_divide() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"
  local rSign="$( bn_result_sign "${a}" "${b}" "div" )"

  a="$( bn_abs "${a}" )"
  b="$( bn_abs "${b}" )"

  bn_eq "${b}" "${BN_0}" && echo "Division by zero detected." 1>&2 && return 1

  local aDigits=( $( bn_digits "${a}" ) )
  local aSize="$( bn_size "${a}" )"
  local bSize="$( bn_size "${b}" )"
  local i=0
  local q=0
  local t=()
  local result=()
  local lastdigit="$( bn_lastdigit "${a}" )"

  for ((i=lastdigit; i>=0; i-- ))
  do
    t=( ${aDigits[$i]} ${t[*]} )
    if bn_le "${b}" "+|${t[*]}"
    then
      q="$( bn_divide_subtraction "+|${t[*]}" "${b}" )"
      local qDigits="$( bn_digits "${q}" )"
      result=( ${qDigits} ${result[*]} )
      t="$( bn_remainder "+|${t[*]}" "${b}" "${q}" )"
      bn_eq "${t}" "${BN_0}" && t=() || t=( $( bn_digits "${t}" ) )
    else
      result=( 0 ${result[*]} )
    fi
  done
  lastdigit="$( bn_lastdigit "+|${#result[*]}" )"

  while [ "${lastdigit}" -gt 0 ] && [ "${result[$lastdigit]}" -eq 0 ]
  do
    unset result[$lastdigit]
    (( lastdigit-- ))
  done

  echo -n "${rSign}|${result[*]}"
}

bn_divide_subtraction() {
  local a="$( bn_sanitize "${1}" )"
  local b="$( bn_sanitize "${2}" )"
  local rSign="$( bn_result_sign "${a}" "${b}" "div" )"

  a="$( bn_abs "${a}" )"
  b="$( bn_abs "${b}" )"
  
  bn_eq "${b}" "${BN_0}" && echo "Division by zero detected." 1>&2 && return 1
  
  local count="${BN_0}"

  while bn_ge "${a}" "${b}"
  do
    count="$( bn_add "${count}" "${BN_1}" )"
    a="$( bn_subtract "${a}" "${b}" )"
  done

  bn_sanitize "${rSign}|$( bn_digits "${count}" )"
}

bn_remainder() {
  local a="$( bn_abs "$( bn_sanitize "${1}" )" )"
  local b="$( bn_abs "$( bn_sanitize "${2}" )" )"
  local q="$( bn_abs "$( bn_sanitize "${3}" )" )"

  bn_subtract "${a}" "$( bn_multiply "${q}" "${b}" )"
}

bn_mod() {
  local a="$( bn_abs "$(bn_sanitize "${1}" )" )"
  local b="$( bn_abs "$(bn_sanitize "${2}" )" )"
  local q="$( bn_abs "$( bn_divide "${a}" "${b}" )" )"

  bn_remainder "${a}" "${b}" "${q}"
}

