import { useState } from "react";

export function SubjectMenuScreen({
  subject,
  sessionKey,
  arbiters,
  loading,
  newSessionKeyCallback,
}: {
  subject: string;
  sessionKey: string;
  arbiters: string[];
  loading: boolean;
  newSessionKeyCallback: () => void;
  addArbiterCallback: (arbiter: string) => void;
}) {
  const arbiterList = arbiters.length ? (
    arbiters.map((address) => (
      <li>
        <small>{address}</small>
      </li>
    ))
  ) : (
    <p>No arbiters for this contract</p>
  );
  return (
    <div className="container">
      <div>
        <span>Contract subject:</span>
        <br />
        <small>{subject}</small>
        <br />
      </div>

      <div>
        <span>Using session key:</span>
        <br />
        <small>{sessionKey}</small>
        <br />
        <button
          className={`btn ${loading ? "loading" : ""}`}
          onClick={newSessionKeyCallback}
        >
          New Session Key
        </button>
      </div>
      <div>
        Arbiters:
        <ul>{arbiterList}</ul>
      </div>
    </div>
  );
}
