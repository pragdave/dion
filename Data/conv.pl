while (<>){
  # Chop the crlf
  chomp ($_);
  $inquotes = 0;

  # this first bit goes through and replaces
  # all the commas that re not in  quotes with tildes
  for ($i=0 ; $i < length($_) ; $i++){
    $char=substr($_,$i,1);
    if ($char eq '"' ){
      $inquotes = not($inquotes);
    }
    else{
      if ( (!$inquotes) && ($char eq ",") ){
        substr($_,$i,1)="~";
      }
    }
  }
  # this replaces any quotes
  s/\"//g;
  print "$_\n";
}
