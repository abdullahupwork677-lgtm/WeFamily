import 'package:flutter/foundation.dart';

/// Avatar SVGs ported 1:1 from the Family Orbit HTML reference `av(t,c)`.
/// Definitions are inlined so each string renders standalone via flutter_svg.
String orbitAvatarSvg(String type, int index) {
  final el = type.length == 2; // elder
  final ch = type == 'b' || type == 'g';
  final sk = 'url(#${index.isOdd ? 'sk2' : 'sk1'})';
  final nk = index.isOdd ? '#c48458' : '#e9b48c';
  final hc = el
      ? 'url(#hg)'
      : (index == 1 || index == 3 ? 'url(#hb)' : 'url(#hk)');
  final hy = ch ? 29 : 26;
  final hr = ch ? 16 : 15;
  final by = ch ? 47 : 41;
  final ey = hy + 1;
  final ry = ch ? 2.8 : 2.3;
  final rx = ch ? 2.2 : 1.8;
  final bc = el ? '#9aa3ab' : '#3a2a20';

  final buffer = StringBuffer();
  buffer.write('<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">');
  buffer.write(_defs);
  buffer.write(
    '<ellipse cx="32" cy="60.5" rx="17" ry="3" fill="rgba(0,0,0,.2)"/>',
  );

  if (type == 'f' || type == 'ef') {
    buffer.write(
      '<path d="M14 29C12 9 24 5 32 5S52 9 50 29C50 41 51 46 47 49H17C13 46 14 41 14 29Z" fill="$hc"/>',
    );
  }
  if (type == 'ef') {
    buffer.write('<circle cx="32" cy="8" r="6" fill="$hc"/>');
  }
  if (type == 'g') {
    buffer.write(
      '<circle cx="13" cy="34" r="6.5" fill="$hc"/><circle cx="51" cy="34" r="6.5" fill="$hc"/>',
    );
  }

  buffer.write(
    '<path d="M9 62C9 ${by + 4} 20 $by 32 $by S55 ${by + 4} 55 62Z" fill="url(#sh$index)"/>'
    '<path d="M26 ${by + 0.5}L32 ${by + 7}L38 ${by + 0.5}" fill="none" stroke="#fff" stroke-opacity=".45" stroke-width="1.6" stroke-linecap="round"/>'
    '<rect x="27" y="${hy + 8}" width="10" height="10" rx="4" fill="$nk"/>'
    '<circle cx="${32 - hr}" cy="${hy + 2}" r="3" fill="$nk"/>'
    '<circle cx="${32 + hr}" cy="${hy + 2}" r="3" fill="$nk"/>'
    '<circle cx="32" cy="$hy" r="$hr" fill="$sk"/>'
    '<ellipse cx="26" cy="${hy - 9}" rx="6" ry="3" fill="#fff" opacity=".28" transform="rotate(-25 26 ${hy - 9})"/>',
  );

  var top =
      'M17 $hy C15 ${hy - 15} 26 ${hy - 18} 33 ${hy - 18} C43 ${hy - 18} 49 ${hy - 12} 47 $hy C44 ${hy - 6} 38 ${hy - 9} 32 ${hy - 9} C26 ${hy - 9} 20 ${hy - 6} 17 $hy Z';
  if (type == 'b') {
    top =
        'M16 $hy C14 ${hy - 13} 21 ${hy - 19} 27 ${hy - 17} L29 ${hy - 22} L33 ${hy - 18} L37 ${hy - 22} L38 $hy C46 $hy 50 ${hy - 11} 48 $hy C44 ${hy - 6} 38 ${hy - 8} 32 ${hy - 8} C26 ${hy - 8} 20 ${hy - 6} 16 $hy Z';
  } else if (type == 'em') {
    top =
        'M16 ${hy + 1} C15 ${hy - 8} 18 ${hy - 12} 21 ${hy - 13} C19 ${hy - 8} 19 ${hy - 4} 20 ${hy + 3} Z M48 ${hy + 1} C49 ${hy - 8} 46 ${hy - 12} 43 ${hy - 13} C45 ${hy - 8} 45 ${hy - 4} 44 ${hy + 3} Z';
  }

  buffer.write(
    '<path d="$top" fill="$hc"/>'
    '<path d="M23 ${hy - 4} Q26 ${hy - 6.5} 29 ${hy - 4} M35 ${hy - 4} Q38 ${hy - 6.5} 41 ${hy - 4}" stroke="$bc" stroke-width="1.6" fill="none" stroke-linecap="round"/>'
    '<ellipse cx="26.5" cy="$ey" rx="$rx" ry="$ry" fill="#2a1d16"/>'
    '<ellipse cx="37.5" cy="$ey" rx="$rx" ry="$ry" fill="#2a1d16"/>'
    '<circle cx="27.2" cy="${ey - 0.9}" r="0.8" fill="#fff"/>'
    '<circle cx="38.2" cy="${ey - 0.9}" r="0.8" fill="#fff"/>'
    '<circle cx="22.5" cy="${hy + 6}" r="3" fill="#ff7f8e" opacity=".35"/>'
    '<circle cx="41.5" cy="${hy + 6}" r="3" fill="#ff7f8e" opacity=".35"/>'
    '<path d="M28 ${hy + 8} Q32 ${hy + 12} 36 ${hy + 8}" stroke="#8a4b3a" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
  );

  if (type == 'em') {
    buffer.write(
      '<path d="M27 ${hy + 7} Q30 ${hy + 4.5} 32 ${hy + 6.5} Q34 ${hy + 4.5} 37 ${hy + 7} Q34 ${hy + 10} 32 ${hy + 8} Q30 ${hy + 10} 27 ${hy + 7} Z" fill="#eef1f4"/>',
    );
  }
  if (el) {
    buffer.write(
      '<g fill="rgba(255,255,255,.25)" stroke="#40342c" stroke-width="1.4">'
      '<circle cx="26.5" cy="$ey" r="4.8"/><circle cx="37.5" cy="$ey" r="4.8"/>'
      '<path d="M31.3 $ey h1.4"/>'
      '</g>',
    );
  }
  if (type == 'g') {
    buffer.write(
      '<g fill="#ff6fa5">'
      '<ellipse cx="44" cy="${hy - 14}" rx="4.5" ry="2.6" transform="rotate(-35 44 ${hy - 14})"/>'
      '<ellipse cx="44" cy="${hy - 14}" rx="4.5" ry="2.6" transform="rotate(35 44 ${hy - 14})"/>'
      '<circle cx="44" cy="${hy - 14}" r="1.8" fill="#e0457f"/>'
      '</g>',
    );
  }

  buffer.write('</svg>');
  return buffer.toString();
}

const _defs = '''
<defs>
<radialGradient id="sk1" cx=".35" cy=".3" r=".85"><stop offset="0" stop-color="#ffe3c8"/><stop offset="1" stop-color="#eeb084"/></radialGradient>
<radialGradient id="sk2" cx=".35" cy=".3" r=".85"><stop offset="0" stop-color="#e8b48a"/><stop offset="1" stop-color="#b87448"/></radialGradient>
<radialGradient id="hk" cx=".35" cy=".25" r=".9"><stop offset="0" stop-color="#6b4a38"/><stop offset="1" stop-color="#1f130d"/></radialGradient>
<radialGradient id="hb" cx=".35" cy=".25" r=".9"><stop offset="0" stop-color="#c08550"/><stop offset="1" stop-color="#6a3e1e"/></radialGradient>
<radialGradient id="hg" cx=".35" cy=".25" r=".9"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#b4bcc5"/></radialGradient>
<linearGradient id="sh0" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#8B5CF6"/><stop offset="1" stop-color="#5B21B6"/></linearGradient>
<linearGradient id="sh1" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#E879F9"/><stop offset="1" stop-color="#C026D3"/></linearGradient>
<linearGradient id="sh2" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#E3C06A"/><stop offset="1" stop-color="#B88A2E"/></linearGradient>
<linearGradient id="sh3" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#9F7AEA"/><stop offset="1" stop-color="#4C1D95"/></linearGradient>
</defs>
''';

@visibleForTesting
int avatarIndex(String id) {
  var h = 0;
  for (var i = 0; i < id.length; i++) {
    h = (h * 31 + id.codeUnitAt(i)) & 0x7fffffff;
  }
  return h % 4;
}
