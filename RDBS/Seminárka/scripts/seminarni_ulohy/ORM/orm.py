from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, func, select
from sqlalchemy.orm import relationship, sessionmaker, declarative_base

# Database setup
DATABASE_URI = 'postgresql://postgres:postgres@localhost:5432/testDB'
engine = create_engine(DATABASE_URI)
Session = sessionmaker(bind=engine)
session = Session()
Base = declarative_base()

# Define the models
class Pavilion(Base):
    __tablename__ = 'pavilion'
    pavilion_id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    est_date = Column(Date, nullable=False)
    animals = relationship("Animal", back_populates="pavilion")

class Animal(Base):
    __tablename__ = 'animal'
    animal_id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    species = Column(String, nullable=False)
    pavilion_id = Column(Integer, ForeignKey('pavilion.pavilion_id'))

    pavilion = relationship("Pavilion", back_populates="animals")


# Subquery to count the animals per pavilion_id
subquery = session.query(
    Animal.pavilion_id,
    func.count(Animal.animal_id).label('animal_count')
).group_by(Animal.pavilion_id).subquery()

# Final query to select pavilion_id and animal_count from the subquery
results = session.query(
    subquery.c.pavilion_id,
    subquery.c.animal_count,
    Pavilion.name
    ).join(Pavilion, Pavilion.pavilion_id == subquery.c.pavilion_id).all()

# Print results
for result in results:
    print(f"Pavilion ID: {result.pavilion_id}, Pavilion name: {result.name}, Animal Count: {result.animal_count}")