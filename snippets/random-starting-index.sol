uint public startingIndexBlock;
uint public startingIndex;

function mint(uint _mintAmount) public payable {
    // mint
    // If we haven't set the starting index and this is either 1) the last saleable token or 2) the first token to be sold after
    // the end of pre-sale, set the starting index block
    if (startingIndexBlock == 0 && (totalSupply() == maxSupply || saleState == 2)) {
        startingIndexBlock = block.number;
    } 
}

function setStartingIndex() public {
    require(startingIndex == 0, "Starting index is already set");
    require(startingIndexBlock != 0, "Starting index block must be set");
    startingIndex = uint(blockhash(startingIndexBlock)) % maxSupply;
    // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
    if (block.number - startingIndexBlock > 255) {
        startingIndex = uint(blockhash(block.number - 1)) % MAX_APES;
    }
    // Prevent default sequence
    if (startingIndex == 0) {
        startingIndex += 1;
    }
}

function emergencySetStartingIndexBlock() public onlyOwner {
    require(startingIndex == 0, "Starting index is already set");
    
    startingIndexBlock = block.number;
}