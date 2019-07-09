2071.sol
function endRound(F3Ddatasets.EventReturns memory _eventData_)
private
returns (F3Ddatasets.EventReturns)
uint256 _rID = rID_;
uint256 _winPID = round_[_rID].plyr;
uint256 _winTID = round_[_rID].team;
uint256 _pot = round_[_rID].pot;
uint256 _win = (_pot.mul(48)) / 100;
uint256 _com = (_pot / 50);
uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);
uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
if (_dust > 0)
_gen = _gen.sub(_dust);
_res = _res.add(_dust);
plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()"))))
_p3d = _p3d.add(_com);
_com = 0;
round_[_rID].mask = _ppt.add(round_[_rID].mask);
if (_p3d > 0)
Divies.deposit.value(_p3d)();
_eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
_eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
_eventData_.winnerAddr = plyr_[_winPID].addr;
_eventData_.winnerName = plyr_[_winPID].name;
_eventData_.amountWon = _win;
_eventData_.genAmount = _gen;
_eventData_.P3DAmount = _p3d;
_eventData_.newPot = _res;
rID_++;
_rID++;
round_[_rID].strt = now;
round_[_rID].end = now.add(rndInit_).add(rndGap_);
round_[_rID].pot = _res;
return(_eventData_);
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
returns(F3Ddatasets.EventReturns)
uint256 _com = _eth / 50;
uint256 _p3d;
if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()"))))
_p3d = _com;
_com = 0;
uint256 _long = _eth / 100;
address(otherF3DInc).call.value(_long)(bytes4(keccak256("deposit()")));
uint256 _aff = _eth / 10;
if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_p3d = _aff;
_p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
if (_p3d > 0)
Divies.deposit.value(_p3d)();
_eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
return(_eventData_);
function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
private
returns(F3Ddatasets.EventReturns)
uint256 _com = _eth / 50;
uint256 _p3d;
if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()"))))
_p3d = _com;
_com = 0;
uint256 _long = _eth / 100;
address(otherF3DInc).call.value(_long)(bytes4(keccak256("deposit()")));
uint256 _aff = _eth / 10;
if (_affID != _pID && plyr_[_affID].name != '') {
plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
} else {
_p3d = _aff;
_p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
if (_p3d > 0)
Divies.deposit.value(_p3d)();
_eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
return(_eventData_);
