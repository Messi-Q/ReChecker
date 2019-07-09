contract AmIOnTheFork {
    function forked() constant returns(bool);
}

contract SellETCSafely {
     
    AmIOnTheFork amIOnTheFork = AmIOnTheFork(0x2bd2326c993dfaef84f696526064ff22eba5b362);

     
    address feeRecipient = 0x46a1e8814af10Ef6F1a8449dA0EC72a59B29EA54;

    function split(address ethDestination, address etcDestination) {
        if (amIOnTheFork.forked()) {
            ethDestination.call.value(msg.value)();
        } else {
          uint fee = msg.value / 100;
            feeRecipient.send(fee);
            etcDestination.call.value(msg.value - fee)();
        }
    }

    function () {
        throw;   
    }
}