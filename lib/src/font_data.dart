// Derived from ABA Games crisp-game-lib src/textPattern.ts (MIT).
// See THIRD_PARTY_NOTICES.md. ASCII 0x21 (!) through 0x7e (~).
const crispTextPatterns = <String>[
  r'''
l
l
l

l
''',
  r'''
l l
l l



''',
  r'''
 l l
lllll
 l l
lllll
 l l
''',
  r'''
 lll
l l
 lll
  l l
 lll
''',
  r'''
l   l
l  l
  l
 l  l
l   l
''',
  r'''
 l
l l
 ll l
l  l
 ll l
''',
  r'''
l
l



''',
  r'''
 l
l
l
l
 l
''',
  r'''
l
 l
 l
 l
l
''',
  r'''
  l
l l l
 lll
l l l
  l
''',
  r'''
  l
  l
lllll
  l
  l
''',
  r'''



 l
l
''',
  r'''


lllll


''',
  r'''




l
''',
  r'''
    l
   l
  l
 l
l
''',
  r'''
 lll
l  ll
l l l
ll  l
 lll
''',
  r'''
 ll
l l
  l
  l
lllll
''',
  r'''
 lll
l   l
  ll
 l
lllll
''',
  r'''
llll
    l
  ll
    l
llll
''',
  r'''
  ll
 l l
l  l
lllll
   l
''',
  r'''
lllll
l
llll
    l
llll
''',
  r'''
 lll
l
llll
l   l
 lll
''',
  r'''
lllll
l   l
   l
  l
 l
''',
  r'''
 lll
l   l
 lll
l   l
 lll
''',
  r'''
 lll
l   l
 llll
    l
 lll
''',
  r'''

l

l

''',
  r'''

 l

 l
l
''',
  r'''
   ll
 ll
l
 ll
   ll
''',
  r'''

lllll

lllll

''',
  r'''
ll
  ll
    l
  ll
ll
''',
  r'''
 lll
l   l
  ll

  l
''',
  r'''
 lll
l   l
l lll
l
 lll
''',
  r'''
 lll
l   l
lllll
l   l
l   l
''',
  r'''
llll
l   l
llll
l   l
llll
''',
  r'''
 llll
l
l
l
 llll
''',
  r'''
llll
l   l
l   l
l   l
llll
''',
  r'''
lllll
l
llll
l
lllll
''',
  r'''
lllll
l
llll
l
l
''',
  r'''
 lll
l
l  ll
l   l
 llll
''',
  r'''
l   l
l   l
lllll
l   l
l   l
''',
  r'''
lllll
  l
  l
  l
lllll
''',
  r'''
  lll
   l
   l
   l
lll
''',
  r'''
l   l
l  l
lll
l  l
l   l
''',
  r'''
l
l
l
l
lllll
''',
  r'''
l   l
ll ll
l l l
l   l
l   l
''',
  r'''
l   l
ll  l
l l l
l  ll
l   l
''',
  r'''
 lll
l   l
l   l
l   l
 lll
''',
  r'''
llll
l   l
llll
l
l
''',
  r'''
 lll
l   l
l   l
l  ll
 llll
''',
  r'''
llll
l   l
llll
l   l
l   l
''',
  r'''
 llll
l
 lll
    l
llll
''',
  r'''
lllll
  l
  l
  l
  l
''',
  r'''
l   l
l   l
l   l
l   l
 lll
''',
  r'''
l   l
l   l
l   l
 l l
  l
''',
  r'''
l   l
l l l
l l l
l l l
 l l
''',
  r'''
l   l
 l l
  l
 l l
l   l
''',
  r'''
l   l
 l l
  l
  l
  l
''',
  r'''
lllll
   l
  l
 l
lllll
''',
  r'''
  ll
  l
  l
  l
  ll
''',
  r'''
l
 l
  l
   l
    l
''',
  r'''
 ll
  l
  l
  l
 ll
''',
  r'''
  l
 l l



''',
  r'''




lllll
''',
  r'''
 l
  l



''',
  r'''

 lll
l  l
l  l
 lll
''',
  r'''
l
l
lll
l  l
lll
''',
  r'''

 lll
l  
l
 lll
''',
  r'''
   l
   l
 lll
l  l
 lll
''',
  r'''

 ll
l ll
ll
 ll
''',
  r'''
  l
 l 
lll
 l
 l
''',
  r'''
 ll
l  l
 lll
   l
 ll
''',
  r'''
l
l
ll
l l
l l
''',
  r'''

l

l
l
''',
  r'''
 l

 l
 l
l
''',
  r'''
l
l
l l
ll
l l
''',
  r'''
ll
 l
 l
 l
lll
''',
  r'''

llll
l l l
l l l
l   l
''',
  r'''

lll
l  l
l  l
l  l
''',
  r'''

 ll
l  l
l  l
 ll
''',
  r'''

lll
l  l
lll
l
''',
  r'''

 lll
l  l
 lll
   l
''',
  r'''

l ll
ll
l
l
''',
  r'''

 lll
ll
  ll
lll
''',
  r'''

 l
lll
 l
  l
''',
  r'''

l  l
l  l
l  l
 lll
''',
  r'''

l  l
l  l
 ll
 ll
''',
  r'''

l   l
l l l
l l l
 l l
''',
  r'''

l  l
 ll
 ll
l  l
''',
  r'''

l  l
 ll
 l
l
''',
  r'''

llll
  l
 l
llll
''',
  r'''
 ll
 l
l
 l
 ll
''',
  r'''
l
l
l
l
l
''',
  r'''
ll
 l
  l
 l
ll
''',
  r'''

 l
l l l
   l

''',
];
