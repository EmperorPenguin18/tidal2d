//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __SFX_H__
#define __SFX_H__

struct Sfx100 {
	int version;
	int wave_type;
	float p_base_freq;
	float p_freq_limit;
	float p_freq_ramp;
	float p_duty;
	float p_duty_ramp;
	float p_vib_strength;
	float p_vib_speed;
	float p_vib_delay;
	float p_env_attack;
	float p_env_sustain;
	float p_env_decay;
	float p_env_punch;
	bool filter_on;
	float p_lpf_resonance;
	float p_lpf_freq;
	float p_lpf_ramp;
	float p_hpf_freq;
	float p_hpf_ramp;
	float p_pha_offset;
	float p_pha_ramp;
	float p_repeat_speed;
};

struct Sfx101 {
	int version;
	int wave_type;
	float p_base_freq;
	float p_freq_limit;
	float p_freq_ramp;
	float p_freq_dramp;
	float p_duty;
	float p_duty_ramp;
	float p_vib_strength;
	float p_vib_speed;
	float p_vib_delay;
	float p_env_attack;
	float p_env_sustain;
	float p_env_decay;
	float p_env_punch;
	bool filter_on;
	float p_lpf_resonance;
	float p_lpf_freq;
	float p_lpf_ramp;
	float p_hpf_freq;
	float p_hpf_ramp;
	float p_pha_offset;
	float p_pha_ramp;
	float p_repeat_speed;
	float p_arp_speed;
	float p_arp_mod;
};

struct Sfx102 {
	int version;
	int wave_type;
	float sound_vol;
	float p_base_freq;
	float p_freq_limit;
	float p_freq_ramp;
	float p_freq_dramp;
	float p_duty;
	float p_duty_ramp;
	float p_vib_strength;
	float p_vib_speed;
	float p_vib_delay;
	float p_env_attack;
	float p_env_sustain;
	float p_env_decay;
	float p_env_punch;
	bool filter_on;
	float p_lpf_resonance;
	float p_lpf_freq;
	float p_lpf_ramp;
	float p_hpf_freq;
	float p_hpf_ramp;
	float p_pha_offset;
	float p_pha_ramp;
	float p_repeat_speed;
	float p_arp_speed;
	float p_arp_mod;
};
typedef struct Sfx102 Sfx;

int load_sfx(Sfx* sfx, void* file) {
	int version = 0;
	memcpy(&version, file, sizeof(int));
	if (version != 102) {
		return -1;
	}
	memcpy(sfx, file, sizeof(Sfx));
	return 0;
}

int sfx2wav(void** wav, size_t* size, Sfx* sfx) {
	*wav = malloc(40);
	// write wav header
	unsigned int dword;
	unsigned short word;
	memcpy(*wav, "RIFF", 4); // "RIFF"
	dword = 0; memcpy(*wav+4, &dword, 4); // remaining file size
	memcpy(*wav+8, "WAVE", 4); // "WAVE"
	memcpy(*wav+12, "fmt ", 4); // "fmt "
	dword = 16; memcpy(*wav+16, &dword, 4); // chunk size
	word = 1; memcpy(*wav+20, &word, 2); // compression code
	word = 1; memcpy(*wav+22, &word, 2); // channels
	dword = wav_freq; memcpy(*wav+24, &dword, 4); // sample rate
	dword = wav_freq*wav_bits/8; memcpy(*wav+28, &dword, 4); // bytes/sec
	word = wav_bits/8; memcpy(*wav+32, &word, 2); // block align
	word = wav_bits; memcpy(*wav+34, &word, 2); // bits per sample
	memcpy(*wav+36, "data", 4); // "data"
	dword = 0; memcpy(*wav+40, &dword, 4); // chunk size
	long int wav_pos = 44;
	// write sample data
	mute_stream=true;
	file_sampleswritten=0;
	filesample=0.0f;
	fileacc=0;
	//Reset without restart
	phase=0;
	fperiod=100.0/(p_base_freq*p_base_freq+0.001);
	period=(int)fperiod;
	fmaxperiod=100.0/(p_freq_limit*p_freq_limit+0.001);
	fslide=1.0-pow((double)p_freq_ramp, 3.0)*0.01;
	fdslide=-pow((double)p_freq_dramp, 3.0)*0.000001;
	square_duty=0.5f-p_duty*0.5f;
	square_slide=-p_duty_ramp*0.00005f;
	if (p_arp_mod>=0.0f) arp_mod=1.0-pow((double)p_arp_mod, 2.0)*0.9;
	else arp_mod=1.0+pow((double)p_arp_mod, 2.0)*10.0;
	arp_time=0;
	arp_limit=(int)(pow(1.0f-p_arp_speed, 2.0f)*20000+32);
	if(p_arp_speed==1.0f) arp_limit=0;
	// reset filter
	fltp=0.0f;
	fltdp=0.0f;
	fltw=pow(p_lpf_freq, 3.0f)*0.1f;
	fltw_d=1.0f+p_lpf_ramp*0.0001f;
	fltdmp=5.0f/(1.0f+pow(p_lpf_resonance, 2.0f)*20.0f)*(0.01f+fltw);
	if(fltdmp>0.8f) fltdmp=0.8f;
	fltphp=0.0f;
	flthp=pow(p_hpf_freq, 2.0f)*0.1f;
	flthp_d=1.0+p_hpf_ramp*0.0003f;
	// reset vibrato
	vib_phase=0.0f;
	vib_speed=pow(p_vib_speed, 2.0f)*0.01f;
	vib_amp=p_vib_strength*0.5f;
	// reset envelope
	env_vol=0.0f;
	env_stage=0;
	env_time=0;
	env_length[0]=(int)(p_env_attack*p_env_attack*100000.0f);
	env_length[1]=(int)(p_env_sustain*p_env_sustain*100000.0f);
	env_length[2]=(int)(p_env_decay*p_env_decay*100000.0f);
	fphase=pow(p_pha_offset, 2.0f)*1020.0f;
	if(p_pha_offset<0.0f) fphase=-fphase;
	fdphase=pow(p_pha_ramp, 2.0f)*1.0f;
	if(p_pha_ramp<0.0f) fdphase=-fdphase;
	iphase=abs((int)fphase);
	ipp=0;
	for(int i=0;i<1024;i++) phaser_buffer[i]=0.0f;
	for(int i=0;i<32;i++) noise_buffer[i]=frnd(2.0f)-1.0f;
	rep_time=0;
	rep_limit=(int)(pow(1.0f-p_repeat_speed, 2.0f)*20000+32);
	if(p_repeat_speed==0.0f) rep_limit=0;
	bool playing_sample = true;
	while(playing_sample) {
		for(int i = 0; i < 256; i++) {
			if(!playing_sample) break;

			rep_time++;
			if(rep_limit!=0 && rep_time>=rep_limit) {
				rep_time=0;
				//Reset with restart
				fperiod=100.0/(p_base_freq*p_base_freq+0.001);
				period=(int)fperiod;
				fmaxperiod=100.0/(p_freq_limit*p_freq_limit+0.001);
				fslide=1.0-pow((double)p_freq_ramp, 3.0)*0.01;
				fdslide=-pow((double)p_freq_dramp, 3.0)*0.000001;
				square_duty=0.5f-p_duty*0.5f;
				square_slide=-p_duty_ramp*0.00005f;
				if(p_arp_mod>=0.0f) arp_mod=1.0-pow((double)p_arp_mod, 2.0)*0.9;
				else arp_mod=1.0+pow((double)p_arp_mod, 2.0)*10.0;
				arp_time=0;
				arp_limit=(int)(pow(1.0f-p_arp_speed, 2.0f)*20000+32);
				if(p_arp_speed==1.0f) arp_limit=0;
			}

			// frequency envelopes/arpeggios
			arp_time++;
			if(arp_limit!=0 && arp_time>=arp_limit) {
				arp_limit=0;
				fperiod*=arp_mod;
			}
			fslide+=fdslide;
			fperiod*=fslide;
			if(fperiod>fmaxperiod) {
				fperiod=fmaxperiod;
				if(p_freq_limit>0.0f) playing_sample=false;
			}
			float rfperiod=fperiod;
			if(vib_amp>0.0f) {
				vib_phase+=vib_speed;
				rfperiod=fperiod*(1.0+sin(vib_phase)*vib_amp);
			}
			period=(int)rfperiod;
			if(period<8) period=8;
			square_duty+=square_slide;
			if(square_duty<0.0f) square_duty=0.0f;
			if(square_duty>0.5f) square_duty=0.5f;
			// volume envelope
			env_time++;
			if(env_time>env_length[env_stage]) {
				env_time=0;
				env_stage++;
				if(env_stage==3) playing_sample=false;
			}
			if (env_stage==0) env_vol=(float)env_time/env_length[0];
			if (env_stage==1) env_vol=1.0f+pow(1.0f-(float)env_time/env_length[1], 1.0f)*2.0f*p_env_punch;
			if (env_stage==2) env_vol=1.0f-(float)env_time/env_length[2];

			// phaser step
			fphase+=fdphase;
			iphase=abs((int)fphase);
			if(iphase>1023) iphase=1023;

			if(flthp_d!=0.0f) {
				flthp*=flthp_d;
				if(flthp<0.00001f) flthp=0.00001f;
				if(flthp>0.1f) flthp=0.1f;
			}

			float ssample=0.0f;
			for(int si=0;si<8;si++) { // 8x supersampling
				float sample=0.0f;
				phase++;
				if(phase>=period) {
					phase%=period;
					if(wave_type==3) {
						for(int i=0;i<32;i++) noise_buffer[i]=frnd(2.0f)-1.0f;
					}
				}
				// base waveform
				float fp=(float)phase/period;
				switch(wave_type) {
				case 0: // square
					if(fp<square_duty)
						sample=0.5f;
					else
						sample=-0.5f;
					break;
				case 1: // sawtooth
					sample=1.0f-fp*2;
					break;
				case 2: // sine
					sample=(float)sin(fp*2*PI);
					break;
				case 3: // noise
					sample=noise_buffer[phase*32/period];
					break;
				}
				// lp filter
				float pp=fltp;
				fltw*=fltw_d;
				if(fltw<0.0f) fltw=0.0f;
				if(fltw>0.1f) fltw=0.1f;
				if(p_lpf_freq!=1.0f) {
					fltdp+=(sample-fltp)*fltw;
					fltdp-=fltdp*fltdmp;
				}
				else {
					fltp=sample;
					fltdp=0.0f;
				}
				fltp+=fltdp;
				// hp filter
				fltphp+=fltp-pp;
				fltphp-=fltphp*flthp;
				sample=fltphp;
				// phaser
				phaser_buffer[ipp&1023]=sample;
				sample+=phaser_buffer[(ipp-iphase+1024)&1023];
				ipp=(ipp+1)&1023;
				// final accumulation and envelope application
				ssample+=sample*env_vol;
			}
			ssample=ssample/8*master_vol;

			ssample*=2.0f*sound_vol;

			// quantize depending on format
			// accumulate/count to accomodate variable sample rate?
			ssample*=4.0f; // arbitrary gain to get reasonable output volume...
			if(ssample>1.0f) ssample=1.0f;
			if(ssample<-1.0f) ssample=-1.0f;
			filesample+=ssample;
			fileacc++;
			if(wav_freq==44100 || fileacc==2) {
				filesample/=fileacc;
				fileacc=0;
				if(wav_bits==16) {
					short isample=(short)(filesample*32000);
					memcpy(*wav+wav_pos, &isample, 2);
					wav_pos += 2;
				}
				else {
					unsigned char isample=(unsigned char)(filesample*127+128);
					memcpy(*wav+wav_pos, &isample, 1);
					wav_pos += 1;
				}
				filesample=0.0f;
			}
			file_sampleswritten++;
		}
	}
	mute_stream=false;
	// seek back to header and write size info
	wav_pos = 4;
	dword = 36+file_sampleswritten*wav_bits/8; memcpy(*wav+wav_pos, &dword, 4); // remaining file size
	wav_pos = 40;
	dword = file_sampleswritten*wav_bits/8; memcpy(*wav+wav_pos, &dword, 4); // chunk size (data)
}

#endif
