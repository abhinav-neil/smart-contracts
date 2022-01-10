  function price() public view returns (uint) {
    if (_tokenId <= 500 ){
        return   0;
    } else if (_tokenId <= 1000 ){
        return   0.01 ether;
    } else if (_tokenId <= 2000 ){
        return   0.02 ether;
    } else if (_tokenId <= 3000 ){
        return   0.03 ether;
    } else if (_tokenId <= 3500 ){
        return   0.04 ether;
    } else {
        return   0.05 ether;
    }
  }

