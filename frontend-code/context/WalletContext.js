import React, {useState,useEffect,useContext} from 'react'
import Web3Modal from "web3modal"
import {ethers} from "ethers"
import axios from "axios"
import {create as ipfsHttpClient} from "ipfs-http-client"

const projectId = () => {
  return (
    <div>WalletContext</div>
  )
}

export default WalletContext