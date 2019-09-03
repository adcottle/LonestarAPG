################################################################################
#                     CREDIT_CARD_VALIDATION_LIB.PL v1.1
#
# Date Created: 12-02-96
# Date Last Modified: 02-07-2000 SPK
$versions{'credit_card_validation_lib.pl'} = "20000207";
#
# Author: Doug Miles
# E-mail: dmiles@primenet.com
#
# Copyright Information: This script was written by Doug Miles
#   having been inspired by countless other perl authors.  Feel free to copy,
#   cite, reference, sample, borrow or plagiarize the contents.  However, if you
#   don't mind, please let me know where it goes so that I can at least
#   watch and take part in the development of the memes. Information
#   wants to be free, support public domain freeware.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Credits:
#
#   Thanks to my friend Mark Schaeffner for a better implementation to the Luhn
#   Check Digit Algorithm.
#
#   Also, thanks to Selena Sol and Gunther Birznieks, whose generosity inspired
#   me to spend just a little bit more time on this library to make it usable
#   and understandable for everyone.
#   (Modified by Steve Kneizys for format MM/DD/YYYY on Feb 7, 2000)
#
################################################################################
sub validate_credit_card_information
{
  local($credit_card_name, $credit_card_number,
        $credit_card_expiration_date) = @_;
  local($invalid);
  $credit_card_name = "\U$credit_card_name\E";

  $invalid = &validate_credit_card_name($credit_card_name);

  if($invalid)
  {

    $error{1} = "I'm sorry, I can't validate $credit_card_name credit cards. \
Please try one of these cards: VISA, MASTERCARD, AMERICAN EXPRESS, \
or DISCOVER.";

    return(%error);

  }
  
  $invalid = &validate_credit_card_number($credit_card_name,
                                          $credit_card_number);

  if($invalid)
  {

    $error{2} = "I'm sorry, $credit_card_number is not a valid number for \
$credit_card_name. Please double check the number and try again.";

    return(%error);

  }
  
  $invalid = &validate_credit_card_expiration_date($credit_card_expiration_date);

  if($invalid)
  {

    $error{3} = "I'm sorry, that credit card has expired, or the date entered \
is invalid.  Please try another card or re-enter the expiration date.";

    return(%error);

  }

# Error is a misnomer here, but error code zero usually means success.

  $error{0} = "Credit card $credit_card_name: $credit_card_number \
$credit_card_expiration_date passed validation.";

  %error;

} 
################################################################################
sub validate_credit_card_name
{

  local($credit_card_name) = @_;
  local($invalid);

  @valid_credit_cards = ("VISA", "MASTERCARD", "AMERICAN EXPRESS", "DISCOVER");

  foreach $valid_credit_card (@valid_credit_cards)
  {

    if($credit_card_name eq $valid_credit_card)
    {

      return(0); # Credit Card Name is Valid.

    }

  }

  return(1); 

} 

################################################################################
sub validate_credit_card_number
{

  local($credit_card_name, $credit_card_number) = @_;
  local($credit_card_number_length, $digit_times_two, $digit,
        @credit_card_number_digit, $validation_number);

  $credit_card_number =~ s/-//g;
  $credit_card_number =~ s/ //g;
  $credit_card_number_length = length($credit_card_number);

  # Make sure that only numbers exist
  if(!($credit_card_number =~ /^[0-9]*$/))
  {

    return(1); 
 
  }

   if($credit_card_name eq "VISA" &&
     ($credit_card_number_length != 13 && $credit_card_number_length != 16))
  {

    return(2); 

  }
  elsif($credit_card_name eq "MASTERCARD" &&
        $credit_card_number_length != 16)
  {

    return(2); 

  }
  elsif($credit_card_name eq "AMERICAN EXPRESS" &&
        $credit_card_number_length != 15)
  {

    return(2); 

  }
  elsif($credit_card_name eq "DISCOVER" &&
        $credit_card_number_length != 16)
  {

    return(2); 

  }

  @credit_card_number_digit = split(/ */, reverse($credit_card_number));

  for($digit_position = 1; $digit_position < $credit_card_number_length;
      $digit_position += 2)
  {

    $digit_times_two = ($credit_card_number_digit[$digit_position] * 2);

    if($digit_times_two > 9)
    {

      $credit_card_number_digit[$digit_position] = ($digit_times_two - 9);

    }
    else
    {

      $credit_card_number_digit[$digit_position] = $digit_times_two;

    }

  }

  $validation_number = 0;

  foreach $digit (@credit_card_number_digit)
  {

    $validation_number += $digit;

  }

  $validation_number % 10;

} 

################################################################################
sub validate_credit_card_expiration_date
{

  local($credit_card_expiration_date) = @_;
  local($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst);
  local($expiration_month,$expiration_day,$expiration_year,$expiration_card);
  local($my_today);

  # Remove dashes, slashes, and spaces from $credit_card_expiration_date.
# Modified by Steve Kneizys for format MM/DD/YYYY

  ($expiration_month,$expiration_day,$expiration_year) = 
         split(/\//,$credit_card_expiration_date,3);
  if ($expiration_year < 100) {
    $expiration_year = $expiration_year + 2000; 
   }
  if ($expiration_day < 1) {
    $expiration_day = 31;
   }

  ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
  localtime(time);
  $mon++;

  $my_today = $mday + 100*($mon + 100*(1900 + $year));
  $expiration_card = 100* (100 * $expiration_year + $expiration_month) 
                     + $expiration_day;

  if($my_today > $expiration_card)
  {
    return(2); 
  }

  return(0); 

} 

1; 
