function truncate(str, limit) 
{
  var bits, i;
  bits = str.split('');
  if (bits.length > limit) {
    for (i = bits.length - 1; i > -1; --i) {
      if (i > limit) {
        bits.length = i;
      }
      else if (' ' === bits[i]) {
        bits.length = i;
        break;
      }
    }
    bits.push('...');
  }
  return bits.join('');
}


function blee( url )
{
  if( url == "/explore")
    window.location = url;
  else
    $.ajax( {url: url, dataType: 'script', method: 'GET'} );
  return false;
}
