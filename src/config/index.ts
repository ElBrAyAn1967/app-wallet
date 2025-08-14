import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'
import { mainnet, arbitrum } from '@reown/appkit/networks'
import type { AppKitNetwork } from '@reown/appkit/networks'
import { Chain } from 'viem/chains'

// Definir la red Monad Testnet
export const monadTestnet: Chain = {
  id: 10143,
  name: 'Monad Testnet',
  nativeCurrency: {
    name: 'Monad',
    symbol: 'MON',
    decimals: 18,
  },
  rpcUrls: {
    default: { http: ['https://testnet-rpc.monad.xyz'] },
    public: { http: ['https://testnet-rpc.monad.xyz'] },
  },
  blockExplorers: {
    default: { name: 'Monad Explorer', url: 'https://testnet.monadexplorer.com' },
  },
  testnet: true,
}

// Get projectId from https://cloud.reown.com
export const projectId =
  process.env.NEXT_PUBLIC_PROJECT_ID ||
  'b56e18d47c72ab683b10814fe9495694' // ProjectId público solo para localhost

if (!projectId) {
  throw new Error('Project ID is not defined')
}

// Agregar Monad Testnet a la lista de redes
export const networks = [mainnet, arbitrum, monadTestnet] as [AppKitNetwork, ...AppKitNetwork[]]

// Set up the Wagmi Adapter (Config)
export const wagmiAdapter = new WagmiAdapter({
  ssr: true,
  projectId,
  networks
})

export const config = wagmiAdapter.wagmiConfig
