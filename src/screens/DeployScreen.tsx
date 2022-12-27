// This screen is not used yet

import { useState } from "react";

export function DeployScreen({
  subject,
  deployCallback,
  sessionKey,
}: {
  subject: string;
  sessionKey: string;
  deployCallback: () => void;
}) {
  const [modalActive, setModalActive] = useState(false);
  const [currentAribiter, setCurrentArbiter] = useState("");
  const [arbiters, setArbiters] = useState<string[]>([]);
  const arbiterList = arbiters.map((address) => (
    <li>
      <small>{address}</small>
      &nbsp; &nbsp;
      <i
        className="icon icon-cross"
        style={{ fontSize: "small" }}
        onClick={() => setArbiters(arbiters.filter((x) => x !== address))}
      ></i>
    </li>
  ));

  return (
    <div className="container">
      <h3>Deploy a new commitment contract</h3>
      <div>
        <span>Logged in as:</span>
        <br />
        <small>{subject}</small>
      </div>
      <div>
        <span>Using session key:</span>
        <br />
        <small>{sessionKey}</small>
      </div>
      <div>
        Arbiters:
        <ul>{arbiterList}</ul>
        <button className="btn" onClick={() => setModalActive(true)}>
          Add Arbiter
        </button>
        <div className={`modal ${modalActive ? "active" : ""}`} id="modal-id">
          <a href="#close" className="modal-overlay" aria-label="Close"></a>
          <div className="modal-container">
            <div className="modal-header">
              <a
                className="btn btn-clear float-right"
                aria-label="Close"
                onClick={() => setModalActive(false)}
              ></a>
              <div className="modal-title h5">Add Arbiter</div>
            </div>
            <div className="modal-body">
              <div className="content">
                <div className="form-group">
                  <label className="form-label" form="">
                    Arbiter's TZ1 Adress:
                    <input
                      className="form-input"
                      id="input-example-7"
                      type="text"
                      placeholder="tz1..."
                      value={currentAribiter}
                      onChange={(e) => {
                        setCurrentArbiter(e.target.value);
                      }}
                    />
                  </label>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button
                className="btn btn-primary"
                onClick={() => {
                  setArbiters([...arbiters, currentAribiter]);
                  setModalActive(false);
                }}
              >
                Add Arbiter
              </button>
            </div>
          </div>
        </div>
      </div>
      <button className="btn btn-primary" onClick={deployCallback}>
        Deploy
      </button>
    </div>
  );
}
