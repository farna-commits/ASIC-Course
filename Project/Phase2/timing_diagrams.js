// Randomizer
{signal: [
    {name: 'clk', wave: 'P|||||'},
    {name: 'reset', wave: '10....'},
    {name: 'load', wave: '010...'},
    {name: 'ready', wave: '0.1..0'},
    {name: 'data in', wave: 'x.333x', data: ['in stream 1', 'in stream 2', 'in stream 3']},
    {name: 'data out', wave: 'x.555x', data: ['out stream 1', 'out stream 2', 'out stream 3']},
    {name: 'valid', wave: '0.1..0'},
  
  ],
   head:{
    text:'Randomizer (ex: 3 streams)',
     tick:0,
   },
  "config" : { "hscale" : 2.5 }
  }
  
  // FEC
  {signal: [
      {name: 'clk_50MHz', wave: 'P|||||', period: 2},
      {name: 'clk_100MHz', wave: 'P|||||||||||', period: 1},
      {name: 'reset', wave: '1.0........'},
      {name: 'ready', wave: '0.1.....0..'},
      {name: 'data in', wave: 'x.3.3.3.x..', data: ['in stream 1', 'in stream 2', 'in stream 3']},
      {name: 'data out', wave: 'x...5.5.5.x', data: ['out stream 1', 'out stream 2', 'out stream 3']},
      {name: 'valid', wave: '0...1.....0'},
    
    ],
     head:{
      text:'FEC Encoder (ex: 3 streams)',
       tick:0,
     },
    "config" : { "hscale" : 2 }
    }
    
  // Interleaver 
  {signal: [
    {name: 'clk_100MHz', wave: 'P|||||', period: 1},
    {name: 'reset', wave: '10....'},
    {name: 'ready', wave: '01..0.'},
    {name: 'data in', wave: 'x333x.', data: ['in stream 1', 'in stream 2', 'in stream 3']},
    {name: 'data out', wave: 'x.555x', data: ['out stream 1', 'out stream 2', 'out stream 3']},
    {name: 'valid', wave: '0.1..0'},
  
  ],
   head:{
    text:'Interleaver (ex: 3 streams)',
     tick:0,
   },
  "config" : { "hscale" : 2.5 }
  }
  
  // Modulator 
  {signal: [
      {name: 'clk_100MHz', wave: 'P...|P..|P..|P..', period: 1},
      {name: 'reset', wave: '10..............'},
      {name: 'ready', wave: '01...........0..'},
      {name: 'data in', wave: 'x3...3...3...x..', data: ['in stream 1', 'in stream 2', 'in stream 3']},
      {name: 'data out', wave: 'x..5...5...5...x', data: ['out stream 1', 'out stream 2','out stream 3']},
      {name: 'valid', wave: '0..1...........0'},
    
    ],
     head:{
      text:'Modulator (ex: 3 streams)',
       tick:0,
     },
    "config" : { "hscale" : 1 }
    }
    
  // Top module 
  {signal: [
      {name: 'clk', wave: 'P.||P||||', period: 2},
      {name: 'reset', wave: '10...............'},
      {name: 'locked', wave: '0.1..............'},
      {name: 'clk_50MHz', wave: '0P||P||||', period: 2},
      {name: 'clk_100MHz', wave: '0.P||||||||||||||', period: 1},  
      {name: 'load', wave: '0.1.0............'},
      {name: 'ready', wave: '0...1.......0....'},
      {name: 'data in', wave: 'x...3.3.3...x....', data: ['in stream 1', 'in stream 2', 'in stream 3']},
      {name: 'data out', wave: 'x.........5.5.5.x', data: ['out 1', 'out 2', 'out 3']},
      {name: 'valid', wave: '0.........1.....0'},
    
    ],
     head:{
      text:'Top Module (ex: 3 streams)',
       tick:0,
     },
    "config" : { "hscale" : 1 }
    }