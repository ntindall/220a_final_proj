// Nathan James Tindall
// Composition 2

//dac => WvOut2 out => blackhole;
//me.sourceDir() + "TINDALL_COMPOSITION.wav" => string _capture;
//_capture => out.wavFilename;

1 => int TRUE;
0 => int FALSE;
600::ms*4 => dur ONE_MEASURE; //of four four
ONE_MEASURE * 4 => dur FOUR_BARS;

Pan2 left => Gain mixer => dac;
left.pan(-1);
Pan2 right => Gain mixer2 => dac;
right.pan(1);

mixer.gain(8);
mixer2.gain(8);

SndBuf harmonics => LPF l => NRev nrev => mixer;
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
    SndBuf theme => LPF z => Gain g => left;
    me.sourceDir() + "clips/themeInF.wav" => theme.read;
    
    SndBuf theme2 => LPF z2 => Gain g2 => right;

    me.sourceDir() + "clips/themeInF.wav" => theme2.read; 

    <<< "Playing theme" >>>;

    g.gain(1);
    g2.gain(1);
 //   g3.gain(0.7);

    spork ~ rampFilterFreq(z, ONE_MEASURE * 24, 200, 400);
    spork ~ rampFilterFreq(z2, ONE_MEASURE * 24, 200, 400);
    spork ~ playBuf(theme, FALSE, ONE_MEASURE * 24, 0.5);
    spork ~ playBuf(theme2, FALSE, ONE_MEASURE * 24, 0.5);
    ONE_MEASURE => now;
    spork ~ play8reverse4(theme, ONE_MEASURE * 23);
    spork ~ play8reverse4slow(theme2, ONE_MEASURE * 23);
    
    ONE_MEASURE * 23 => now;
}

fun void bass(dur duration) {
    SndBuf bass => PitShift p => bassLPF => nrev => dac;
    me.sourceDir() + "clips/etherealC.wav" => bass.read;
    bass.rate(0.25);
    p.shift(0.5);
    p.mix(0.5);
   
    spork ~ playBuf(bass, FALSE, duration, 0.05);
    ONE_MEASURE * 24 => now;
}

LPF z2;
fun void themeFast(dur duration) {
    SndBuf theme => z2 => PitShift p => Gain g => left;
    me.sourceDir() + "clips/themeInF.wav" => theme.read;
    left.pan(-1);
    theme.rate(8);
    p.shift(2);

    SndBuf theme2 => z2 =>  Gain g2 => right;
    me.sourceDir() + "clips/themeInF.wav" => theme2.read; 
    right.pan(1);
    <<< "Playing theme faster " >>>;
    theme2.rate(8);

    g.gain(0.01);
    g2.gain(0.01);

    spork ~ playBuf(theme, FALSE, duration, 1);
    spork ~ playBuf(theme2, FALSE, duration, 1);
    duration => now;
}

//pass in negative speed for REVERSE~~å
fun void scrub(SndBuf theme, FilterBasic filter, dur duration, float speed, float shift, float rate, int should_repeat, int left) {
    now => time start;

    filter => PitShift s => ADSR e => Gain g => nrev;
    rate => theme.rate;
    shift => s.shift;
    e.releaseTime(1000::ms);
    e.releaseRate(0.001);
    e.attackTime(1000::ms);

    0 => theme.pos;  //init
    g.gain(4);

    e.keyOn(1);

    while (start + duration - e.releaseTime() > now) {
        while ((start + duration - e.releaseTime() > now) && (theme.pos() < theme.samples())) {
            
            Math.random2(0, theme.samples()) => theme.pos;
            
            <<< theme.pos() >>>;
            ONE_MEASURE / speed => now;

        }
        if ((should_repeat == TRUE) && (start + duration - e.releaseTime() > now)) {
            0 => theme.pos;
        }
    }
    e.keyOff(1);
    e.releaseTime() => now;
    <<< "Scrub releasing" >>>;

}

fun void intro() {
    for (int i; i < 4; i++) { 
        spork ~ rampFilterFreq(z2, ONE_MEASURE, 1000, 2000);
        themeFast(1::second);
    }
}

fun void lowC(dur duration) {
    SndBuf lowC => LPF l => Gain g => nrev;
    me.sourceDir() + "clips/lowChit.wav" => lowC.read;
    l.freq(1000);
    lowC.rate(1);
    g.gain(0.5);
   
    spork ~ playBuf(lowC, FALSE, duration, 0.05);
    duration => now;
}


/* CONTROL FLOW *******************************************************/

spork ~lowC(ONE_MEASURE *8 + ONE_MEASURE);
ONE_MEASURE /2 => now;

nrev.mix(0.05);
//speed shift rate
LPF scrubLPF;
SndBuf scrubTheme1 => scrubLPF;
me.sourceDir() + "clips/themeInF.wav" => scrubTheme1.read;

SndBuf scrubTheme2 => scrubLPF;
me.sourceDir() + "clips/themeInF.wav" => scrubTheme2.read;

/*
for (int i; i < 4; i++) {
    spork ~ rampFilterFreq(scrubLPF, ONE_MEASURE, 40, 30);
    spork ~ scrub(scrubTheme1, scrubLPF, ONE_MEASURE, 0.5, 1, 0.5, TRUE, 0);
    spork ~ scrub(scrubTheme2, scrubLPF, ONE_MEASURE, 0.5, 1, 0.5, TRUE, 1);
    ONE_MEASURE * 2 => now;
    <<< i >>>;
}
spork ~lowC(ONE_MEASURE *8 + ONE_MEASURE);
ONE_MEASURE /2 => now;

for (int i; i < 4; i++) {
    spork ~ rampFilterFreq(scrubLPF, ONE_MEASURE, 40, 60);
    spork ~ scrub(scrubTheme1, scrubLPF, ONE_MEASURE, 0.5, 1, 1, TRUE, 0);
    spork ~ scrub(scrubTheme2, scrubLPF, ONE_MEASURE, 0.5, 1, 1, TRUE, 1);
    ONE_MEASURE * 2 => now;
    <<< i >>>;
}
*/
//spork ~bass(ONE_MEASURE*26);
/*
for (int i; i< 2; i++) {
    spork ~lowC(ONE_MEASURE *3);
    ONE_MEASURE*2 => now;
} 
for (int i; i < 8; i++) {
    nrev.mix(0.05);
    spork ~lowC(ONE_MEASURE * 2);
    spork ~ rampFilterFreq(scrubLPF, ONE_MEASURE*2, 100, 100);
    spork ~ scrub(scrubTheme1, scrubLPF, ONE_MEASURE*2, 1, 1, 2, TRUE, 0);
    spork ~ scrub(scrubTheme2, scrubLPF, ONE_MEASURE*2, 1, 1, 2, TRUE, 1);
    ONE_MEASURE*2 => now;
    <<< i >>>;
}*//*
spork ~ rampFilterFreq(scrubLPF, ONE_MEASURE*8, 100, 100);
<<< "Reverse" >>>;
spork ~lowC(ONE_MEASURE *3);
spork ~ scrub(scrubTheme2, scrubLPF, ONE_MEASURE*8, 0.5, 1, 2, TRUE, 1);
scrubTheme1.gain(0.5);
scrub(scrubTheme1, scrubLPF, ONE_MEASURE*8, 0.25, 1, -1, TRUE, 0);
//spork ~bass(ONE_MEASURE*26);

/* CLIMAX 
scrubTheme2.gain(0.5); //woah now!
<<< "Adjusting Gain">>>;
spork ~ rampFilterFreq(scrubLPF, ONE_MEASURE*16, 100, 100);
spork ~scrub(scrubTheme2, scrubLPF, ONE_MEASURE*16, 0.0625, 4, -0.5, TRUE, 0);
spork~ bass(ONE_MEASURE *32);
for (int i; i< 8; i++) {
    lowC(ONE_MEASURE*2);
}
*/
/* INTRODUCTION */

scrubTheme1.gain(0);
scrubTheme2.gain(0.25);
spork ~ rampFilterFreq(scrubLPF, ONE_MEASURE*16, 40, 40); //just a rumble
spork ~scrub(scrubTheme2, scrubLPF, ONE_MEASURE*40, 0.0625, 4, -0.25, TRUE, 0);
spork ~theme(); //24 measures
ONE_MEASURE * 16 => now;
spork ~ bass(ONE_MEASURE *24);


for (int i; i < 8; i++) {
    spork ~ playBuf(harmonics, FALSE, ONE_MEASURE, 0.5);
    ONE_MEASURE => now;
}

 /* MORE */

spork ~ rampFilterFreq(bassLPF, ONE_MEASURE * 16, 100, 10000);
ONE_MEASURE *16 => now;


//1::day => now;
//out.closeFile();
