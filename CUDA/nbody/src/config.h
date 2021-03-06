#ifndef _CONFIG_H_
#define _CONFIG_H_


const unsigned int window_width = 1366;
const unsigned int window_height = 768;

//---------------------------------

#define bodies 16384
#define threads 64

#define explosion2Factor 9500.0f
#define explosionFactor 12320.0f
#define distanceMultiplier 20.0f
#define randomFactor 100.0f
#define whirlSpeed 200.0f
#define centerMass 30000.0f


/* default values:
=== 16384 bodies ===
#define bodies 16384
#define threads 64

#define explosion2Factor 9500.0f
#define explosionFactor 12320.0f
#define distanceMultiplier 20.0f
#define randomFactor 100.0f
#define whirlSpeed 200.0f
#define centerMass 30000.0f

-------------------------------------------

=== 4096 bodies ===
#define bodies 4096
#define threads 64

#define explosion2Factor 6500.0f
#define explosionFactor 7320.0f
#define distanceMultiplier 20.0f
#define randomFactor 50.0f
#define whirlSpeed 200.0f
#define centerMass 30000.0f
*/

#endif
