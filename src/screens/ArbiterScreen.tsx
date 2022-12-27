export function ArbiterScreen({
  subject,
  upToDate,
  claimStakeCallback,
}: {
  subject: string;
  upToDate: boolean;
  claimStakeCallback: () => void;
}) {
  return (
    <div className="container">
      <div>
        <span>Subject:</span>
        <br />
        <small>{subject}</small>
      </div>
      {(() => {
        if (upToDate) {
          return <p>Subject is up-to-date on commitment 👍</p>;
        } else {
          return (
            <>
              <p>Subject is behind on commitment 😬</p>
              <button className="btn btn-error" onClick={claimStakeCallback}>
                Claim Stake
              </button>
            </>
          );
        }
      })()}
    </div>
  );
}
