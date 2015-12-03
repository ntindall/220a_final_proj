// Nathan James Tindall
// Composition 2

//dac => WvOut2 out => blackhole;
//me.sourceDir() + "TINDALL_COMPOSITION.wav" => string _capture;
//_capture => out.wavFilename;

1 => int TRUE;
0 => int FALSE;
600::ms*4 => dur ONE_MEASURE; //of four four
ONE_MEASURE * 4 => dur FOUR_BARS;

SndBuf harmonics => LPF l => NRev nrev => dac;
me.sourceDir() + "clips/4bars-harmonic-CG-100bpm.wav" => harmonics.read;
0 => harmonics.gain;

//mix
l.freq(200);
nrev.mix(0.05);

LPF l2; //global so that can be referenced out of polychord
l2.freq(200);

LPF bassLPF; //global so that can be referenced out of bass
bassLPF.freq(100);

Pan2 p2;

fun void rhythm(dur duration ) {
    Shakers drops => Gain g;
    Shakers sticks => g;
    
    g => JCRev r => Pan2 p => dac;
    
    0.2 => g.gain;
    
    now => time start;
    // set the gain
    0.95 => r.gain;
    // set the reverb mix
    .025 => r.mix;
   
    4 => drops.which; //drops
    8 => sticks.which; //sticks
    0 => sticks.decay;
    // our main loop
    while(start + duration > now )
    {  
        Math.random2f( -1, 1 ) => p.pan;
        Math.random2f( 0, 128 ) => drops.noteOn;
        
           Math.random2f( 0, 128 ) => sticks.noteOn;
        drops.energy(0.5);
        sticks.energy(0.5);
        150::ms => now; 
    }
}

fun void reverse(SndBuf buf) {
    buf.rate() * -1 => buf.rate;   
}

fun void play8reverse4(SndBuf buf, dur duration) {
    now => time start;
  
    while (start + duration > now) {
        ONE_MEASURE * 2 => now; //8 beats forward
        reverse(buf);
        buf.pos() => int pos;
        ONE_MEASURE => now;     //4 beats back
        reverse(buf);
        pos => buf.pos;
    }   
}

fun void play8reverse4slow(SndBuf buf, dur duration) {
    now => time start;
    
    while (start + duration > now) {
        ONE_MEASURE * 2 => now; //8 beats forward
        reverse(buf);
        buf.rate() / 2 => buf.rate; //slow 
        buf.pos() => int pos;
        ONE_MEASURE => now;     //4 beats back
        reverse(buf);
        buf.rate() * 2 => buf.rate; //requicken
        pos => buf.pos;
    }   
}

fun void playBuf(SndBuf buf, int should_repeat, dur duration, float gain) {
    now => time start;

    0 => buf.pos;  //init
    gain => buf.gain; //turn on buf

    while (start + duration > now) {
        while ((start + duration > now) && (buf.pos() < buf.samples())) {
            30::samp => now;
        }

        if ((should_repeat == TRUE) && (start + duration > now)) {
            0 => buf.pos;
        }
    }

    0 => buf.pos;  //good housekeeping
    0 => buf.gain; //turn off buf
}

fun void rampFilterFreq(FilterBasic f, dur duration, float startFreq, float endFreq) {
    now => time startTime;

    100 => int numSteps;
    (endFreq - startFreq) / numSteps => float delta; //how much pitch has to change

    startFreq => f.freq;

    while (startTime + duration > now) {
        f.freq() + delta => f.freq;
        duration / numSteps => now;
    }
}

fun void rampPan(Pan2 pan, dur duration, float start, float end) {
    now => time startTime;

    100 => int numSteps;
    (end - start) / numSteps => float delta; //how much pitch has to change

    start => pan.pan;

    while (startTime + duration > now) {
     //   <<< pan.pan() >>>;
        pan.pan() + delta => pan.pan;
        duration / numSteps => now;
    }
}

fun void polychord() {
    SndBuf polychord => l2 => nrev => Gain g => p2 => dac;
    me.sourceDir() + "clips/polychord-123-100bpm.wav" => polychord.read;
    0.2 => g.gain;
    spork ~ rampPan(p2, ONE_MEASURE*1.75, -1, 1);
    spork ~ playBuf(polychord, FALSE, ONE_MEASURE * 2, 0.1);
    ONE_MEASURE * 1.75 => now;
    spork ~ rampPan(p2, ONE_MEASURE*0.25, 1, -1);
    ONE_MEASURE*0.25 => now;
}


fun void theme() {
    SndBuf theme => LPF z => nrev => Gain g => Pan2 left => dac;
    me.sourceDir() + "clips/themeInF.wav" => theme.read;
    left.pan(-1);
    
    SndBuf theme2 => z => l2 => nrev => g => Pan2 right => dac;
    me.sourceDir() + "clips/themeInF.wav" => theme2.read; 
    right.pan(1);
    <<< "Playing theme" >>>;

    g.gain(3);
    spork ~ rampFilterFreq(z, ONE_MEASURE * 24, 100, 200);
    spork ~ playBuf(theme, FALSE, ONE_MEASURE * 24, 0.5);
    spork ~ playBuf(theme2, FALSE, ONE_MEASURE * 24, 0.5);
    ONE_MEASURE => now;
    spork ~ play8reverse4(theme, ONE_MEASURE * 23);
    spork ~ play8reverse4slow(theme2, ONE_MEASURE * 23);
    
    ONE_MEASURE * 23 => now;
}

fun void bass(dur duration) {
    SndBuf bass => PitShift p => l2 => nrev => dac;
    me.sourceDir() + "clips/etherealC.wav" => bass.read;
    bass.rate(0.25);
    p.shift(0.5);
    p.mix(0.5);
   
    spork ~ playBuf(bass, FALSE, duration, 0.05);
    ONE_MEASURE * 24 => now;
}

LPF z2;
fun void themeFast() {
    SndBuf theme => z2 => nrev => Gain g => Pan2 left => PitShift p => dac;
    me.sourceDir() + "clips/themeInF.wav" => theme.read;
    left.pan(-1);
    theme.rate(8);
    p.shift(0.5);

    SndBuf theme2 => z2 => nrev => g => Pan2 right => dac;
    me.sourceDir() + "clips/themeInF.wav" => theme2.read; 
    right.pan(1);
    <<< "Playing theme faster " >>>;
    theme2.rate(8);

    g.gain(2);
    spork ~ playBuf(theme, FALSE, ONE_MEASURE * 2, 0.01);
    spork ~ playBuf(theme2, FALSE, ONE_MEASURE * 2, 0.01);
    ONE_MEASURE => now;
    spork ~ play8reverse4(theme, ONE_MEASURE);
    spork ~ play8reverse4slow(theme2, ONE_MEASURE);
    
    ONE_MEASURE/4 => now;
}

fun void intro() {
    for (int i; i < 4; i++) { 
        spork ~ rampFilterFreq(z2, ONE_MEASURE, 1000, 2000);
        themeFast();
    }
}
/* CONTROL FLOW *******************************************************/

nrev.mix(0.4);
intro();
ONE_MEASURE *2 => now;
nrev.mix(0.05);
/* INTRODUCTION */

spork ~ theme();
ONE_MEASURE * 16 => now;
for (int i; i < 8; i++) {
    spork ~ playBuf(harmonics, FALSE, ONE_MEASURE, 0.5);
    ONE_MEASURE => now;
}

 /* MORE */

spork ~ rampFilterFreq(bassLPF, ONE_MEASURE * 24, 100, 10000);
spork ~ bass(ONE_MEASURE *24);

//polychord();

for (int i; i < 4; i++) {
    spork ~ playBuf(harmonics, FALSE, ONE_MEASURE, 0.5);
    ONE_MEASURE => now;
}

spork ~ rampFilterFreq(l2, ONE_MEASURE * 16, 100, 400);

for (int i; i < 8; i++) {
    spork ~ polychord();
    spork ~ playBuf(harmonics, FALSE, ONE_MEASURE, 0.5);
    ONE_MEASURE*2 => now;
}


rhythm(ONE_MEASURE);
1::day => now;
//out.closeFile();
