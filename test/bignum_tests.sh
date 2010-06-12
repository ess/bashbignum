#!/bin/bash - 
#===============================================================================
#
#          FILE:  bignum_tests.sh
# 
#         USAGE:  ./bignum_tests.sh 
# 
#   DESCRIPTION:  Unit tests for bignum.sh
# 
#===============================================================================

source ../bignum.sh

testIntMax() {
  local max=$( int_max 1 0 )

  assertEquals "int_max appears to be broken" "1" "${max}"
}

testBignumDetection() {
  local a='12345'
  local nega='-12345'
  local b='+|5 4 3 2 1'

  is_bignum "${a}" && fail "'${a}' is a bignum"
  is_bignum "${nega}" && fail "'${nega}' is a bignum"
  is_bignum "${b}" || "'${b}' is not a bignum"
}

testBignumCreation() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_create -12345 )"
  local z="$( bn_create 0 )"
  local negz="$( bn_create -0 )"

  assertEquals "a != '+|5 4 3 2 1'" '+|5 4 3 2 1' "${a}"
  assertEquals "nega != '-|5 4 3 2 1'" '-|5 4 3 2 1' "${nega}"
  assertEquals "z != '+|0'" '+|0' "${z}"
  assertEquals "negz != '+|0'; 0 is always positive" '+|0' "${negz}"
}

testBignumSign() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"

  assertTrue "${a} is negative" "[ "$( bn_sign "${a}" )" == '+' ]"
  assertTrue "${nega} is positive" "[ "$( bn_sign "${nega}" )" == '-' ]"
}

testBignumNegation() {
  local p="$( bn_create '1' )"
  local n="$( bn_create '-1' )"
  local z="$( bn_create '0' )"

  bn_eq "$( bn_negate "${p}" )" "${n}" ||
  fail "-p != n"

  bn_eq "$( bn_negate "${n}" )" "${p}" ||
  fail "-n != p"

  bn_eq "$( bn_negate "${z}" )" "${z}" ||
  fail "-0 != 0"
}

testBignumAbs() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"

  bn_eq "$( bn_abs "${nega}" )" "${a}" ||
  fail "abs(${nega}) != ${a}"
}

testBignumComparisons() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_create -12345 )"
  local b="$( bn_create 12345 )"
  local negb="$( bn_create '-12345' )"
  local z="$( bn_create 0 )"
  local negz="$( bn_create '-0' )"

  bn_eq "${a}" "${b}" || fail "bn_eq a b:  '${a}' != '${b}'"
  bn_eq "${nega}" "${negb}" || fail "bn_eq nega negb:  '${nega}' != '${negb}'"
  bn_eq "${a}" "${nega}" && fail "bn_eq a nega:  '${a}' != '${nega}'"
  bn_eq "${b}" "${negb}" && fail "bn_eq b negb:  '${b}' != '${negb}'"
  bn_eq "${z}" "${negz}" || fail "bn_eq z negz:  '${z}' == '${negz}'"

  bn_gt "${a}" "${b}" && fail "bn_gt a b:  '${a}' == '${b}'"
  bn_gt "${a}" "${nega}" || fail "bn_gt a nega:  '${a}' <= '${nega}'"
  bn_gt "${a}" "${z}" || fail "bn_gt a z: '${a}' <= '${z}'"
}

testBignumDetectSign() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"

  assertTrue "${a} is negative" "[ \"$( bn_sign "${a}" )\" == '+' ]"
  assertTrue "${nega} is positive" "[ \"$( bn_sign "${nega}" )\" == '-' ]"

  is_pos "${a}" || fail "'is_pos ${a}' returned false"
  is_pos "${nega}" && fail "'is_pos ${nega}' returned true"
  is_neg "${a}" && fail "'is_pos ${a}' returned true"
  is_neg "${nega}" || fail "'is_neg ${nega}' returned false"
}

testBignumSize() {
  local a="$( bn_create 12345 )"

  assertEquals "bn_size '${a}' != 5" "$( bn_size "${a}" )" 5
}

testBignumDigits() {
  local a="$( bn_create 12345 )"

  assertEquals "bn_digits '${a}' != '5 4 3 2 1'" "$( bn_digits "${a}" )" '5 4 3 2 1'
}

testBignumAppend() {
  local a="$( bn_create 12345 )"

  assertEquals "bn_append '${a}' != '1 5 4 3 2 1'" "$( bn_append "${a[*]}" "${BN_1}" )" "$( bn_create 123451 )"
}

testBignumPrepend() {
  local a="$( bn_create 12345 )"

  assertEquals "bn_prepend '${a}' != '5 4 3 2 1 1'" "$( bn_prepend "${a[*]}" "${BN_1}" )" "$( bn_create 112345 )"
}

testBignumLastdigit() {
  true
}

testBignumSanitize() {
  local a='+|4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0'

  assertEquals "Sanitize failed." "$( bn_sanitize "${a}" )" '+|4'
}

testBignumToString() {
  local a="$( bn_create '-123456789' )"

  assertEquals "ToString failed." "$( bn_to_string "${a}" )" '-123456789'
}

testBignumLarger() {
  local a="$( bn_create 12345 )"
  local b="$( bn_create 54321 )"
  local nega="$( bn_negate "${a}" )"
  local negb="$( bn_negate "${b}" )"

  assertEquals "Larger failed on a,b" "$( bn_larger "${a}" "${b}" )" '+|1 2 3 4 5'
  assertEquals "Larger failed on b,a" "$( bn_larger "${b}" "${a}" )" '+|1 2 3 4 5'
  assertEquals "Larger failed on a,nega" "$( bn_larger "${a}" "${nega}" )" '+|5 4 3 2 1'
  assertEquals "Larger failed on b,negb" "$( bn_larger "${b}" "${negb}" )" '+|1 2 3 4 5'
}

testBignumSmaller() {
  local a="$( bn_create 12345 )"
  local b="$( bn_create 54321 )"
  local nega="$( bn_negate "${a}" )"
  local negb="$( bn_negate "${b}" )"

  assertEquals "Smaller failed on a,b" "$( bn_smaller "${a}" "${b}" )" '+|5 4 3 2 1'
  assertEquals "Smaller failed on b,a" "$( bn_smaller "${b}" "${a}" )" '+|5 4 3 2 1'
  assertEquals "Smaller failed on a,nega" "$( bn_smaller "${a}" "${nega}" )" '-|5 4 3 2 1'
  assertEquals "Smaller failed on b,negb" "$( bn_smaller "${b}" "${negb}" )" '-|1 2 3 4 5'
}

testBignumShift() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"
  local z="${BN_0}"

  assertEquals "Shift failed on a" "$( bn_shift "${a}" 1 )" '+|0 5 4 3 2 1'
  assertEquals "Shift failed on nega" "$( bn_shift "${nega}" 1 )" '-|0 5 4 3 2 1'
  assertEquals "Shift failed on z" "$( bn_shift "${z}" )" "${BN_0}"
}

testBignumResultSign() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"
  local op=''

  fail "ResultSign fails for op='add'"
  fail "ResultSign fails for op='sub'"

  for op in mul div
  do
    echo "Testing ResultSign for op='${op}'"
    assertEquals "ResultSign failed on a,a,${op}" "$( bn_result_sign "${a}" "${a}" "${op}" )" '+'
    assertEquals "ResultSign failed on a,nega,${op}" "$( bn_result_sign "${a}" "${nega}" "${op}" )" '-'
    assertEquals "ResultSign failed on nega,nega,${op}" "$( bn_result_sign "${nega}" "${nega}" "${op}" )" '+'
  done
}

testBignumAddition() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"
  local b="$( bn_create 54321 )"
  local negb="$( bn_negate "${b}" )"
  local z="$( bn_create 0 )"
  local t=''

  # a + a = 24690
  t="$( bn_create '24690')"
  bn_eq "${t}" "$( bn_add "${a}" "${a}" )" ||
  fail "'${a}' + '${a}' != '${t}'"

  #  a + b = 66666
  t="$( bn_create '66666')"
  bn_eq "${t}" "$( bn_add "${a}" "${b}" )" ||
  fail "'${a}' + '${b}' != '${t}'"

  #  a + nega = 0
  t="${z}"
  bn_eq "${t}" "$( bn_add "${a}" "${nega}" )" ||
  fail "'${a}' + '${nega}' != '${t}'"

  #  a + negb = -41976
  t="$( bn_create '-41976')"
  bn_eq "${t}" "$( bn_add "${a}" "${negb}" )" ||
  fail "'${a}' + '${negb}' != '${t}'"

  #  a + z = 12345
  t="$( bn_create '12345')"
  bn_eq "${t}" "$( bn_add "${a}" "${z}" )" ||
  fail "'${a}' + '${z}' != '${t}'"

  #  b + b = 108642
  t="$( bn_create '108642')"
  bn_eq "${t}" "$( bn_add "${b}" "${b}" )" ||
  fail "'${b}' + '${b}' != '${t}'"

  #  b + nega = 41976
  t="$( bn_create '41976')"
  bn_eq "${t}" "$( bn_add "${b}" "${nega}" )" ||
  fail "'${b}' + '${nega}' != '${t}'"

  #  b + negb = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_add "${b}" "${negb}" )" ||
  fail "'${b}' + '${negb}' != '${t}'"

  #  b + z = 54321
  t="$( bn_create '54321')"
  bn_eq "${t}" "$( bn_add "${b}" "${z}" )" ||
  fail "'${b}' + '${z}' != '${t}'"

}

testBignumSubtraction() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"
  local b="$( bn_create 54321 )"
  local negb="$( bn_negate "${b}" )"
  local z="$( bn_create 0 )"
  local t=''

  #  a - a = 0 
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_subtract "${a}" "${a}" )" ||
  fail "'${a}' - '${a}' != '${t}'"

  #  a - b = -41976
  t="$( bn_create '-41976')"
  bn_eq "${t}" "$( bn_subtract "${a}" "${b}" )" ||
  fail "'${a}' - '${b}' != '${t}'"

  #  a - nega = 24690
  t="$( bn_create '24690')"
  bn_eq "${t}" "$( bn_subtract "${a}" "${nega}" )" ||
  fail "'${a}' - '${nega}' != '${t}'"

  #  a - negb = 66666
  t="$( bn_create '66666')"
  bn_eq "${t}" "$( bn_subtract "${a}" "${negb}" )" ||
  fail "'${a}' - '${negb}' != '${t}'"

  #  a - z = 12345
  t="$( bn_create '12345')"
  bn_eq "${t}" "$( bn_subtract "${a}" "${z}" )" ||
  fail "'${a}' - '${z}' != '${t}'"

  #  b - b = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_subtract "${b}" "${b}" )" ||
  fail "'${b}' - '${b}' != '${t}'"

  #  b - nega = 66666
  t="$( bn_create '66666')"
  bn_eq "${t}" "$( bn_subtract "${b}" "${nega}" )" ||
  fail "'${b}' - '${nega}' != '${t}'"

  #  b - negb = 108642
  t="$( bn_create '108642')"
  bn_eq "${t}" "$( bn_subtract "${b}" "${negb}" )" ||
  fail "'${b}' - '${negb}' != '${t}'"

  #  b - z = 54321
  t="$( bn_create '54321')"
  bn_eq "${t}" "$( bn_subtract "${b}" "${z}" )" ||
  fail "'${b}' - '${z}' != '${t}'"

  #  z - a = -12345
  t="$( bn_create '-12345')"
  bn_eq "${t}" "$( bn_subtract "${z}" "${a}" )" ||
  fail "'${z}' - '${a}' != '${t}'"

  #  z - nega = 12345
  t="$( bn_create '12345')"
  bn_eq "${t}" "$( bn_subtract "${z}" "${nega}" )" ||
  fail "'${z}' - '${nega}' != '${t}'"

}

testBignumMultiplication() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"
  local b="$( bn_create 54321 )"
  local negb="$( bn_negate "${b}" )"
  local z="$( bn_create 0 )"
  local t=''

  #  a * a = 152399025
  t="$( bn_create '152399025')"
  bn_eq "${t}" "$( bn_multiply "${a}" "${a}" )" ||
  fail "'${a}' * '${a}' != '${t}'"

  #  a * b = 670592745
  t="$( bn_create '670592745')"
  bn_eq "${t}" "$( bn_multiply "${a}" "${b}" )" ||
  fail "'${a}' * '${b}' != '${t}'"

  #  a * nega = -152399025
  t="$( bn_create '-152399025')"
  bn_eq "${t}" "$( bn_multiply "${a}" "${nega}" )" ||
  fail "'${a}' * '${nega}' != '${t}'"

  #  a * negb = -670592745
  t="$( bn_create '-670592745')"
  bn_eq "${t}" "$( bn_multiply "${a}" "${negb}" )" ||
  fail "'${a}' * '${negb}' != '${t}'"

  #  a * z = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_multiply "${a}" "${z}" )" ||
  fail "'${a}' * '${z}' != '${t}'"

  #  b * b = 2950771041
  t="$( bn_create '2950771041')"
  bn_eq "${t}" "$( bn_multiply "${b}" "${b}" )" ||
  fail "'${b}' * '${b}' != '${t}'"

  #  b * nega = -670592745
  t="$( bn_create '-670592745')"
  bn_eq "${t}" "$( bn_multiply "${b}" "${nega}" )" ||
  fail "'${b}' * '${nega}' != '${t}'"

  #  b * negb = -2950771041
  t="$( bn_create '-2950771041')"
  bn_eq "${t}" "$( bn_multiply "${b}" "${negb}" )" ||
  fail "'${b}' * '${negb}' != '${t}'"

  #  b * z = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_multiply "${b}" "${z}" )" ||
  fail "'${b}' * '${z}' != '${t}'"

}

testBignumDivision() {
  local a="$( bn_create 12345 )"
  local nega="$( bn_negate "${a}" )"
  local b="$( bn_create 54321 )"
  local negb="$( bn_negate "${b}" )"
  local z="$( bn_create 0 )"
  local t=''

  #  a / a = 1
  t="$( bn_create '1')"
  bn_eq "${t}" "$( bn_divide "${a}" "${a}" )" ||
  fail "'${a}' / '${a}' != '${t}'"

  #  a / b = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_divide "${a}" "${b}" )" ||
  fail "'${a}' / '${b}' != '${t}'"

  #  a / nega = -1
  t="$( bn_create '-1')"
  bn_eq "${t}" "$( bn_divide "${a}" "${nega}" )" ||
  fail "'${a}' / '${nega}' != '${t}'"

  #  a / negb = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_divide "${a}" "${negb}" )" ||
  fail "'${a}' / '${negb}' != '${t}'"

  #  a / z = ERROR
  t='ERROR'
  bn_divide "${a}" "${z}" && 
  fail "'${a}' / '${z}' != '${t}'"

  #  b / a = 4
  t="$( bn_create '4')"
  bn_eq "${t}" "$( bn_divide "${b}" "${a}" )" ||
  fail "'${b}' / '${a}' != '${t}'"

  #  b / b = 1
  t="$( bn_create '1')"
  bn_eq "${t}" "$( bn_divide "${b}" "${b}" )" ||
  fail "'${b}' / '${b}' != '${t}'"

  #  b / nega = -4
  t="$( bn_create '-4')"
  bn_eq "${t}" "$( bn_divide "${b}" "${nega}" )" ||
  fail "'${b}' / '${nega}' != '${t}'"

  #  b / negb = -1
  t="$( bn_create '-1')"
  bn_eq "${t}" "$( bn_divide "${b}" "${negb}" )" ||
  fail "'${b}' / '${negb}' != '${t}'"

  #  b / z = ERROR
  t='ERROR'
  bn_divide "${b}" "${z}" && 
  fail "'${b}' / '${z}' != '${t}'"

  #  z / a = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_divide "${z}" "${a}" )" ||
  fail "'${z}' / '${a}' != '${t}'"

  #  z / nega = 0
  t="$( bn_create '0')"
  bn_eq "${t}" "$( bn_divide "${z}" "${nega}" )" ||
  fail "'${z}' / '${nega}' != '${t}'"

  #  z / z = ERROR
  t='ERROR'
  bn_divide "${z}" "${z}" &&
  fail "'${z}' / '${z}' != '${t}'"
}

testBignumRemainder() {
  local a="$( bn_create 777 )"
  local b="$( bn_create 20 )"
  local q="$( bn_create 38 )"
  local rem="$( bn_create 17 )"

  assertEquals "a - ( q * b ) != 17" "$( bn_remainder "${a}" "${b}" "${q}" )" "${rem}"
}

testBignumMod() {
  local a="$( bn_create 777 )"
  local b="$( bn_create 20 )"
  local rem="$( bn_create 17 )"

  assertEquals "${a} % ${b} != ${rem}" "$( bn_mod "${a}" "${b}" )" "${rem}"
}

# source shunit2-2.1.5 to actually run the tests
# shunit2 is available at http://code.google.com/p/shunit2/

source ./shunit2/shunit2
