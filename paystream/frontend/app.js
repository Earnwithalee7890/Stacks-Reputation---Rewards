
// Basic Mock of Stacks.js for the HTML demo
// In a real app, this would use the actual stacks.js library via NPM or CDN

const contractAddress = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
const contractName = 'paystream';

document.getElementById('connect-wallet').addEventListener('click', async () => {
    // Simulate wallet connection
    console.log("Connecting wallet...");
    alert("Wallet Connected (Mock)!");
    document.getElementById('wallet-status').innerText = "Connected: ST1PQ...PGZGM";
});

document.getElementById('create-stream-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const recipient = document.getElementById('recipient').value;
    const amount = document.getElementById('amount').value;
    const duration = document.getElementById('duration').value;

    console.log(`Creating stream to ${recipient} for ${amount} STX over ${duration} blocks.`);

    // Simulate contract call
    alert(`Stream Created! ID: ${Math.floor(Math.random() * 1000)}`);

    // Add to UI list
    const list = document.getElementById('stream-list');
    const item = document.createElement('li');
    item.className = "p-4 bg-gray-800 rounded mb-2 flex justify-between";
    item.innerHTML = `
        <span>To: ${recipient.substr(0, 6)}...</span>
        <span>${amount} STX</span>
        <button class="text-green-400 hover:text-green-300">Withdraw</button>
    `;
    list.appendChild(item);
});
