import { InMemorySigner } from "@taquito/signer";
import { TezosToolkit } from "@taquito/taquito";

import { useEffect, useState } from "react";
import { CommitScreen } from "./screens/CommitScreen";
import { SubjectMenuScreen } from "./screens/SubjectMenuScreen";
import * as human from "human-crypto-keys";
import { convertPrivateKey } from "./utils";

// Not used yet
// import { ArbiterScreen } from "./screens/ArbiterScreen";
// import { DeployScreen} from "./screens/DeployScreen"

const CONTRACT_HASH = "KT1HJhEvsgogmqVBgBj56SYrEJ1QtFiyugfB";
const SUBJECT = "tz1MCkDAhUqx2f7QkyWgawp1CzDyX4t3br7c";

const SESSION_KEY_LOCATION = "commitment-device.sessionKey";

const newPrivateKey = async () => {
  const rawKeypair = await human.generateKeyPair("ed25519");
  const privateKey = convertPrivateKey(rawKeypair);
  return privateKey;
};

type screens = "commit" | "subject-menu";

const Tezos = new TezosToolkit("https://ghostnet.ecadinfra.com/");

export function App() {
  const [errorMessage, setErrorMessage] = useState("");
  const [screen, setScreen] = useState<screens>("commit");
  const subject = SUBJECT;
  const [sessionKey, setSessionKey] = useState<string | null>(null);
  const [arbiters, setArbiters] = useState<string[]>([]);
  const [lastKeepAlive, setLastKeepAlive] = useState<Date | undefined>(
    undefined
  );
  const [loading, setLoading] = useState(false);

  const loadSessionKey = async (privateKey: string) => {
    const sessionWallet = await InMemorySigner.fromSecretKey(privateKey);
    const sessionPublicKeyHash = await sessionWallet.publicKeyHash();
    Tezos.setProvider({ signer: sessionWallet });

    setLoading(false);
    setSessionKey(sessionPublicKeyHash);
  };

  useEffect(() => {
    (async () => {
      let privateKey = localStorage.getItem(SESSION_KEY_LOCATION);
      if (privateKey === null) {
        privateKey = await newPrivateKey();
        localStorage.setItem(SESSION_KEY_LOCATION, privateKey);
      }
      loadSessionKey(privateKey);
    })();
  }, []);

  const updateStorage = async () => {
    const contract = await Tezos.contract.at(CONTRACT_HASH);
    const { arbiters, last_keep_alive } = (await contract.storage()) as any;
    setArbiters(arbiters);
    setLastKeepAlive(new Date(last_keep_alive));
  };
  useEffect(() => {
    updateStorage();
  }, []);

  const keepAliveCallback = async () => {
    setErrorMessage("");
    try {
      setLoading(true);
      const contract = await Tezos.contract.at(CONTRACT_HASH);
      const op = await contract.methods.keep_alive().send();

      await op.confirmation(2);
      await updateStorage();
    } catch (error: any) {
      console.error(error);
      setErrorMessage(error.toString());
    } finally {
      setLoading(false);
    }
  };
  const addArbiter = async (arbiter: string) => {
    setLoading(true);
    const contract = await Tezos.contract.at(CONTRACT_HASH);
    const op = await contract.methods.add_arbiter(arbiter).send();
    await op.confirmation(2);
    setLoading(false);
  };
  switch (screen) {
    case "commit":
      return (
        <>
          <a
            className="off-canvas-toggle btn-action"
            id="menu"
            onClick={() => setScreen("subject-menu")}
          >
            <i className="icon icon-menu"></i>
          </a>
          <CommitScreen
            errorMessage={errorMessage}
            loading={loading}
            contract={CONTRACT_HASH}
            keepAliveCallback={keepAliveCallback}
            lastCommit={lastKeepAlive!}
          />
        </>
      );
    case "subject-menu":
      return (
        <>
          <a
            className="off-canvas-toggle btn-action"
            id="menu"
            onClick={() => setScreen("commit")}
          >
            <i className="icon icon-cross"></i>
          </a>
          <SubjectMenuScreen
            loading={loading}
            subject={subject}
            arbiters={arbiters}
            sessionKey={sessionKey!}
            addArbiterCallback={addArbiter}
            newSessionKeyCallback={async () => {
              loadSessionKey(await newPrivateKey());
            }}
          />
        </>
      );
    default:
      throw new Error("unreachable");
  }
}
