'use strict'

fetch('coindata.json')
.then(response => response.json())
.then(data => drawGraphs(data));

function drawGraphs(coins)
{
  let body = document.getElementsByTagName("body")[0];

  Object.keys(coins).forEach(x => {
    console.log(x);
    console.log(coins[x])

    let text = document.createElement('p');
    text.innerText = `${x} (${coins[x]})`;
    body.appendChild(text);

    let graphDiv = document.createElement('div');
    graphDiv.style="width:95vw";
    text.innerText = `${x} (${coins[x]})`; 
    body.appendChild(graphDiv);

    new Dygraph(
      graphDiv,
      `data/${x}.csv`
    );

  });
}