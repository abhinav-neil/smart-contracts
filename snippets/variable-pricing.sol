function price() public view returns (uint) {
uint _id = totalSupply();
if (_id <= 1000 ){
    return   0.1 ether;
} else if (_id <= 2000 ){
    return   0.2 ether;
} else if (_id <= 3000 ){
    return   0.3 ether;
}
}